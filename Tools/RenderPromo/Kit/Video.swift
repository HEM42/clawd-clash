import AppKit
import AVFoundation

// Writing the video: every frame to H.264, muxed with the soundtrack, and the small copy for GitHub.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Video

/// The small copy GitHub plays inline (it takes uploads up to 10 MB): 1280×720 H.264 at a bitrate that brings the whole
/// video, with its 128 kb/s sound, to about 9.5 MB, capped at 1.6 Mb/s for short ones.
func write720p(from input: String, to output: String) {
    let asset = AVURLAsset(url: URL(fileURLWithPath: input))
    let out = URL(fileURLWithPath: output); try? FileManager.default.removeItem(at: out)
    try? FileManager.default.createDirectory(at: out.deletingLastPathComponent(), withIntermediateDirectories: true)
    let seconds = asset.duration.seconds
    // long videos overshoot the average a little, so they aim lower; busy ones (halftones, fine pixel detail) can still
    // overshoot, so a copy over 9.7 MB is made again at a bitrate cut by as much as it went over
    var bitrate = Int(min(1_600_000, (seconds > 90 ? 8_900_000 : 9_500_000) * 8 / seconds - 128_000))
    for attempt in 0..<3 {
        let size = encode720p(asset, to: out, bitrate: bitrate)
        print(String(format: "wrote %@ (%.1f MB at %d kb/s)", output, Double(size) / 1_000_000, bitrate / 1000))
        if size <= 9_700_000 || attempt == 2 { return }
        let audio = 128_000.0 * seconds / 8, target = 9_300_000.0
        bitrate = Int(Double(bitrate) * pow((target - audio) / (Double(size) - audio), 1.6))   // it shrinks less than the bitrate does
    }
}

/// One 1280×720 H.264 encode of `asset` at `bitrate`, with its sound as 128 kb/s AAC; the file's size in bytes.
func encode720p(_ asset: AVURLAsset, to out: URL, bitrate: Int) -> Int {
    try? FileManager.default.removeItem(at: out)
    let reader = try! AVAssetReader(asset: asset)
    let vt = asset.tracks(withMediaType: .video)[0], at = asset.tracks(withMediaType: .audio)[0]
    let vOut = AVAssetReaderTrackOutput(track: vt, outputSettings: [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA])
    let aOut = AVAssetReaderTrackOutput(track: at, outputSettings: [AVFormatIDKey: kAudioFormatLinearPCM])
    reader.add(vOut); reader.add(aOut)
    let writer = try! AVAssetWriter(outputURL: out, fileType: .mp4)
    let vIn = AVAssetWriterInput(mediaType: .video, outputSettings: [AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: 1280, AVVideoHeightKey: 720,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspect,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel, AVVideoMaxKeyFrameIntervalKey: 90]])
    let aIn = AVAssetWriterInput(mediaType: .audio, outputSettings: [AVFormatIDKey: kAudioFormatMPEG4AAC, AVSampleRateKey: 44100, AVNumberOfChannelsKey: 1, AVEncoderBitRateKey: 128000])
    writer.add(vIn); writer.add(aIn)
    reader.startReading(); writer.startWriting(); writer.startSession(atSourceTime: .zero)
    let group = DispatchGroup()
    for (input, output, q) in [(vIn, vOut, DispatchQueue(label: "video")), (aIn, aOut, DispatchQueue(label: "audio"))] {
        group.enter()
        input.requestMediaDataWhenReady(on: q) {
            while input.isReadyForMoreMediaData {
                if let sample = output.copyNextSampleBuffer() { input.append(sample) } else { input.markAsFinished(); group.leave(); return }
            }
        }
    }
    group.wait()
    let done = DispatchSemaphore(value: 0); writer.finishWriting { done.signal() }; done.wait()
    if writer.status != .completed { print("720p failed: \(String(describing: writer.error))"); exit(1) }
    return (try? FileManager.default.attributesOfItem(atPath: out.path)[.size] as? Int) ?? 0
}

/// Puts the soundtrack under the silent video: WAV → AAC with afconvert, then a passthrough export.
func mux(video: String, audio: String, to out: String) {
    let m4a = audio.replacingOccurrences(of: ".wav", with: ".m4a")
    try? FileManager.default.removeItem(atPath: m4a)
    let p = Process()
    p.executableURL = URL(fileURLWithPath: "/usr/bin/afconvert")
    p.arguments = ["-f", "m4af", "-d", "aac", "-b", "192000", audio, m4a]
    try! p.run(); p.waitUntilExit()

    let comp = AVMutableComposition()
    let v = AVURLAsset(url: URL(fileURLWithPath: video)), a = AVURLAsset(url: URL(fileURLWithPath: m4a))
    let range = CMTimeRange(start: .zero, duration: CMTime(seconds: duration, preferredTimescale: 600))
    let vt = comp.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)!
    try! vt.insertTimeRange(range, of: v.tracks(withMediaType: .video)[0], at: .zero)
    let at = comp.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
    let aRange = CMTimeRange(start: .zero, duration: min(range.duration, a.duration))
    try! at.insertTimeRange(aRange, of: a.tracks(withMediaType: .audio)[0], at: .zero)
    try? FileManager.default.removeItem(atPath: out)
    let ex = AVAssetExportSession(asset: comp, presetName: AVAssetExportPresetPassthrough)!
    ex.outputURL = URL(fileURLWithPath: out); ex.outputFileType = .mp4
    let done = DispatchSemaphore(value: 0)
    ex.exportAsynchronously { done.signal() }
    done.wait()
    if ex.status != .completed { print("mux failed: \(String(describing: ex.error))"); exit(1) }
    print("wrote \(out)")
}


/// Encodes every frame straight into an H.264 MP4 with AVAssetWriter (no ffmpeg needed).
func writeVideo(to path: String) {
    let url = URL(fileURLWithPath: path)
    try? FileManager.default.removeItem(at: url)
    let writer = try! AVAssetWriter(outputURL: url, fileType: .mp4)
    // 16 Mb/s, but never so much that the file passes 95 MB: GitHub refuses to take a file over 100 MB, and the
    // seven-universe promo (68 s) came out at 115 MB.
    let bitrate = Int(min(16_000_000, 95_000_000 * 8 / duration - 128_000))
    let input = AVAssetWriterInput(mediaType: .video, outputSettings: [
        AVVideoCodecKey: AVVideoCodecType.h264, AVVideoWidthKey: W, AVVideoHeightKey: H,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: bitrate, AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel],
    ])
    let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB, kCVPixelBufferWidthKey as String: W,
        kCVPixelBufferHeightKey as String: H,
    ])
    writer.add(input)
    writer.startWriting(); writer.startSession(atSourceTime: .zero)
    let n = Int(duration * fps)
    for f in 0..<n {
        autoreleasepool {
            while !input.isReadyForMoreMediaData { Thread.sleep(forTimeInterval: 0.005) }
            var pb: CVPixelBuffer?
            CVPixelBufferPoolCreatePixelBuffer(nil, adaptor.pixelBufferPool!, &pb)
            let buf = pb!
            CVPixelBufferLockBaseAddress(buf, [])
            let ctx = CGContext(data: CVPixelBufferGetBaseAddress(buf), width: W, height: H, bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buf), space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)!
            ctx.draw(frame(Double(f) / fps).cgImage!, in: CGRect(x: 0, y: 0, width: W, height: H))
            CVPixelBufferUnlockBaseAddress(buf, [])
            adaptor.append(buf, withPresentationTime: CMTime(value: CMTimeValue(f), timescale: CMTimeScale(fps)))
        }
    }
    input.markAsFinished()
    let done = DispatchSemaphore(value: 0)
    writer.finishWriting { done.signal() }
    done.wait()
    if writer.status != .completed { print("video failed: \(String(describing: writer.error))"); exit(1) }
    print("wrote \(path)")
}
