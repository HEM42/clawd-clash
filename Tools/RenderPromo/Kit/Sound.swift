import AppKit

// The soundtrack, all synthesized here: the mix, the sound effects, the groove and the master.
// Part of RenderPromo's kit: declarations only. main.swift picks the reel and runs it; its header has the build
// command.

// MARK: Soundtrack (all synthesized here: an original chiptune score and retro sound effects)

let sampleRate = 44100.0
func hashNoise(_ i: Int) -> Double { noise(i) }   // the sprites' noise, reachable from inside Mix

/// A mono mix bus the whole soundtrack is written into.
final class Mix {
    var buf: [Float]
    init(seconds: Double) { buf = [Float](repeating: 0, count: Int(seconds * sampleRate) + 1) }

    enum Wave { case square(Double), saw, triangle, sine }

    /// One note or sweep: `freq` slides to `to`, with an attack/release envelope and optional vibrato.
    func tone(_ start: Double, _ dur: Double, _ freq: Double, to: Double? = nil, wave: Wave = .square(0.5), vol: Double,
              attack: Double = 0.005, release: Double = 0.05, decay: Double = 0, vibrato: Double = 0) {
        guard start < Double(buf.count) / sampleRate, dur > 0 else { return }
        let n = Int(dur * sampleRate), s0 = Int(max(0, start) * sampleRate)
        var phase = 0.0
        for i in 0..<n {
            let idx = s0 + i
            guard idx < buf.count else { break }
            let tt = Double(i) / sampleRate, p = tt / dur
            var f = to.map { freq * pow($0 / freq, p) } ?? freq
            if vibrato > 0 { f *= 1 + vibrato * sin(tt * 2 * .pi * 5.5) }
            phase += f / sampleRate
            let ph = phase - floor(phase)
            let v: Double
            switch wave {
            case .square(let duty): v = ph < duty ? 1 : -1
            case .saw: v = 2 * ph - 1
            case .triangle: v = ph < 0.5 ? 4 * ph - 1 : 3 - 4 * ph
            case .sine: v = sin(2 * .pi * ph)
            }
            var env = min(1, tt / attack) * min(1, (dur - tt) / release)
            if decay > 0 { env *= exp(-tt / decay) }
            buf[idx] += Float(v * env * vol)
        }
    }

    /// Filtered noise: `cutoff` (0…1, one-pole low-pass amount) slides to `cutoffTo`; `highpass` keeps only the hiss.
    func noise(_ start: Double, _ dur: Double, vol: Double, cutoff: Double = 1, cutoffTo: Double? = nil,
               attack: Double = 0.002, release: Double = 0.05, decay: Double = 0, highpass: Bool = false, seed: Int = 1) {
        let n = Int(dur * sampleRate), s0 = Int(max(0, start) * sampleRate)
        var lp = 0.0, rng = UInt64(seed &* 2654435761 &+ 12345)
        for i in 0..<n {
            let idx = s0 + i
            guard idx < buf.count else { break }
            rng = rng &* 6364136223846793005 &+ 1442695040888963407
            let white = Double(Int64(bitPattern: rng >> 11) % 2_000_000) / 1_000_000 - 1
            let tt = Double(i) / sampleRate, p = tt / dur
            let a = cutoffTo.map { cutoff + ($0 - cutoff) * p } ?? cutoff
            lp += (white - lp) * a
            let v = highpass ? white - lp : lp
            var env = min(1, tt / attack) * min(1, max(0, dur - tt) / release)
            if decay > 0 { env *= exp(-tt / decay) }
            buf[idx] += Float(v * env * vol)
        }
    }

    // Sound effects
    func pew(_ t: Double, vol: Double = 0.16) {                       // hand blaster
        tone(t, 0.2, 1900, to: 220, wave: .square(0.5), vol: vol, release: 0.08, decay: 0.09)
        noise(t, 0.05, vol: vol * 0.5, cutoff: 0.6, decay: 0.02)
    }
    func turbolaser(_ t: Double, pitch: Double, vol: Double = 0.1) {
        tone(t, 0.32, 900 * pitch, to: 110 * pitch, wave: .saw, vol: vol, release: 0.1, decay: 0.14)
        noise(t, 0.12, vol: vol * 0.6, cutoff: 0.25, decay: 0.05, seed: Int(t * 100))
    }
    func clash(_ t: Double, vol: Double = 0.2) {                      // sabers meeting
        noise(t, 0.22, vol: vol, cutoff: 0.9, decay: 0.06, highpass: true, seed: Int(t * 77))
        tone(t, 0.18, 1400, to: 500, wave: .square(0.3), vol: vol * 0.35, decay: 0.05)
        tone(t, 0.25, 180, to: 120, wave: .saw, vol: vol * 0.4, decay: 0.1)
    }
    func ignite(_ t: Double, vol: Double = 0.14) {
        tone(t, 0.5, 70, to: 120, wave: .saw, vol: vol, attack: 0.02, release: 0.2)
        noise(t, 0.3, vol: vol * 0.5, cutoff: 0.05, cutoffTo: 0.4, decay: 0.15, seed: 9)
    }
    func hum(_ t: Double, _ dur: Double, vol: Double = 0.035) {        // saber hum while blades are out
        tone(t, dur, 92, wave: .saw, vol: vol, attack: 0.3, release: 0.4, vibrato: 0.01)
        tone(t, dur, 94.5, wave: .saw, vol: vol, attack: 0.3, release: 0.4)
    }
    func boom(_ t: Double, vol: Double = 0.45) {
        tone(t, 1.2, 90, to: 32, wave: .sine, vol: vol, release: 0.4, decay: 0.45)
        noise(t, 0.8, vol: vol * 0.5, cutoff: 0.08, cutoffTo: 0.01, decay: 0.3, seed: Int(t * 13))
    }
    func whoosh(_ center: Double, _ dur: Double, vol: Double = 0.12) {
        noise(center - dur / 2, dur, vol: vol, cutoff: 0.01, cutoffTo: 0.25, attack: dur * 0.5, release: dur * 0.5, seed: Int(center * 31))
    }
    func pop(_ t: Double, step: Int, vol: Double = 0.1) {
        let f = 520 * pow(2, Double(step) * 4 / 12)
        tone(t, 0.09, f, to: f * 1.6, wave: .square(0.25), vol: vol, release: 0.03)
    }
    func ping(_ t: Double, vol: Double = 0.16) {                      // notification
        tone(t, 0.25, 1318.5, wave: .sine, vol: vol, release: 0.2, decay: 0.15)
        tone(t + 0.12, 0.45, 1760, wave: .sine, vol: vol, release: 0.35, decay: 0.2)
    }
    func step(_ t: Double, vol: Double = 0.05) { noise(t, 0.04, vol: vol, cutoff: 0.15, decay: 0.012, seed: Int(t * 997)) }
    func click(_ t: Double, vol: Double = 0.1) {                      // a laptop key
        noise(t, 0.025, vol: vol, cutoff: 0.3, decay: 0.008, highpass: true, seed: Int(t * 541))
        noise(t, 0.03, vol: vol * 0.5, cutoff: 0.15, decay: 0.01, seed: Int(t * 613))
    }
    func r2(_ t: Double, vol: Double = 0.07) {                       // a little droid chirp
        for k in 0..<10 {
            let f = 1100 + hashNoise(Int(t * 10) + k * 3) * 1700
            tone(t + Double(k) * 0.045, 0.05, f, to: f * (hashNoise(k + 4) > 0.5 ? 1.3 : 0.8), wave: .sine, vol: vol, release: 0.01)
        }
    }
    // Drums
    func kick(_ t: Double, vol: Double = 0.3) { tone(t, 0.16, 150, to: 45, wave: .sine, vol: vol, release: 0.05, decay: 0.08) }
    func snare(_ t: Double, vol: Double = 0.12) {
        noise(t, 0.14, vol: vol, cutoff: 0.7, decay: 0.05, seed: Int(t * 61))
        tone(t, 0.08, 220, to: 160, wave: .triangle, vol: vol * 0.5, decay: 0.04)
    }
    func hat(_ t: Double, vol: Double = 0.035) { noise(t, 0.04, vol: vol, cutoff: 0.95, decay: 0.012, highpass: true, seed: Int(t * 173)) }
}

func midi(_ n: Int) -> Double { 440 * pow(2, Double(n - 69) / 12) }

/// Writes 16-bit mono PCM as a WAV file.
func writeWAV(_ samples: [Float], to path: String) {
    var d = Data()
    func u32(_ v: UInt32) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 4)) }
    func u16(_ v: UInt16) { var x = v.littleEndian; d.append(Data(bytes: &x, count: 2)) }
    d.append("RIFF".data(using: .ascii)!); u32(UInt32(36 + samples.count * 2)); d.append("WAVEfmt ".data(using: .ascii)!)
    u32(16); u16(1); u16(1); u32(UInt32(sampleRate)); u32(UInt32(sampleRate) * 2); u16(2); u16(16)
    d.append("data".data(using: .ascii)!); u32(UInt32(samples.count * 2))
    var pcm = [Int16](repeating: 0, count: samples.count)
    for i in samples.indices { pcm[i] = Int16(max(-1, min(1, samples[i])) * 32000) }
    pcm.withUnsafeBufferPointer { d.append(Data(buffer: $0)) }
    try! d.write(to: URL(fileURLWithPath: path))
}

func shotStart(_ name: String) -> Double { shots.first { $0.name == name }!.start }

/// Every time the duelling blades meet (the same clock the sparks use) between `a` and `b`.
func clashTimes(_ a: Double, _ b: Double) -> [Double] {
    var out: [Double] = [], was = false
    var t = a
    while t < b {
        let c = duelPose(t).clash
        if c && !was { out.append(t) }
        was = c; t += 1 / 120
    }
    return out
}

/// When a blaster with `offset` fires between `a` and `b` (a bolt leaves at each whole period).
func shotTimes(_ a: Double, _ b: Double, offset: Double) -> [Double] {
    var out: [Double] = []
    var k = ceil((a + offset) / blasterPeriod)
    while k * blasterPeriod - offset < b { out.append(k * blasterPeriod - offset); k += 1 }
    return out
}

// Marvel sound effects
extension Mix {
    func type(_ t: Double, vol: Double = 0.22) {                     // a typewriter key: the strike, then the thunk
        noise(t, 0.04, vol: vol, cutoff: 0.25, decay: 0.012, highpass: true, seed: Int(t * 733))
        noise(t, 0.06, vol: vol * 0.8, cutoff: 0.12, decay: 0.02, seed: Int(t * 977))
        tone(t, 0.05, 150, to: 90, wave: .triangle, vol: vol * 0.7, decay: 0.018)
    }
    func ding(_ t: Double, vol: Double = 0.12) {                     // the bell at the end of the line
        tone(t, 0.9, 2093, wave: .sine, vol: vol, release: 0.6, decay: 0.35)
        tone(t, 0.6, 4186, wave: .sine, vol: vol * 0.3, release: 0.4, decay: 0.2)
    }
    func flip(_ t: Double, vol: Double = 0.06) {                     // a comic page turning
        noise(t, 0.09, vol: vol, cutoff: 0.05, cutoffTo: 0.5, attack: 0.03, release: 0.04, seed: Int(t * 389))
    }
    func clang(_ t: Double, vol: Double = 0.12) {                    // a shot off Cap's shield
        for (f, d) in [(1250.0, 0.35), (1870.0, 0.25), (2930.0, 0.18)] { tone(t, d, f, wave: .sine, vol: vol / 2, release: 0.1, decay: d / 3) }
        noise(t, 0.03, vol: vol * 0.7, cutoff: 0.9, decay: 0.01, highpass: true, seed: Int(t * 91))
    }
    func repulsor(_ t: Double, vol: Double = 0.1) {                  // Iron Man's palm blast
        tone(t, 0.28, 2400, to: 700, wave: .sine, vol: vol, release: 0.1, decay: 0.12)
        noise(t, 0.2, vol: vol * 0.7, cutoff: 0.5, cutoffTo: 0.05, decay: 0.08, seed: Int(t * 57))
    }
    func thwip(_ t: Double, vol: Double = 0.1) {                     // a web shot
        noise(t, 0.12, vol: vol, cutoff: 0.1, cutoffTo: 0.9, attack: 0.01, release: 0.05, seed: Int(t * 211))
        tone(t, 0.1, 600, to: 1600, wave: .triangle, vol: vol * 0.4, release: 0.04)
    }
    func bomb(_ t: Double, vol: Double = 0.1) {                      // a pumpkin bomb: lobbed, then a pop
        tone(t, 0.18, 400, to: 900, wave: .square(0.3), vol: vol * 0.4, release: 0.05)
        noise(t + 0.36, 0.25, vol: vol, cutoff: 0.3, cutoffTo: 0.03, decay: 0.09, seed: Int(t * 17))
    }
    func roar(_ t: Double, _ dur: Double, vol: Double = 0.2) {       // a Leviathan bellowing
        tone(t, dur, 75, to: 48, wave: .saw, vol: vol, attack: 0.15, release: dur * 0.4, vibrato: 0.06)
        tone(t, dur, 112, to: 70, wave: .saw, vol: vol * 0.6, attack: 0.2, release: dur * 0.4, vibrato: 0.08)
        noise(t, dur, vol: vol * 0.7, cutoff: 0.04, cutoffTo: 0.015, attack: 0.15, release: dur * 0.4, seed: Int(t * 3))
    }
    func crackle(_ t: Double, _ dur: Double, vol: Double = 0.05) {   // a magic beam, Thanos' gauntlet
        tone(t, dur, 160, wave: .saw, vol: vol, attack: 0.1, release: 0.2, vibrato: 0.04)
        noise(t, dur, vol: vol * 0.8, cutoff: 0.6, attack: 0.1, release: 0.2, highpass: true, seed: Int(t * 29))
    }
    func groot(_ t: Double, vol: Double = 0.08) {                    // a low, friendly rumble, three notes
        for (k, n) in [43, 45, 40].enumerated() {
            tone(t + Double(k) * 0.22, 0.24, midi(n), wave: .triangle, vol: vol, attack: 0.03, release: 0.08, vibrato: 0.02)
        }
    }
    func jet(_ t: Double, _ dur: Double, vol: Double = 0.06) {       // the Quinjet going by
        tone(t, dur, 700, to: 1100, wave: .saw, vol: vol * 0.4, attack: dur * 0.4, release: dur * 0.5)
        noise(t, dur, vol: vol * 2, cutoff: 0.02, cutoffTo: 0.3, attack: dur * 0.45, release: dur * 0.5, seed: 77)
    }
}

/// When a ranged fighter with `offset` lets a shot go between `a` and `b`.
func fireTimes(_ a: Double, _ b: Double, offset: Double) -> [Double] { shotTimes(a, b, offset: offset) }


// DC sound effects
extension Mix {
    func rain(_ t: Double, _ dur: Double, vol: Double = 0.05) {      // a Gotham downpour
        noise(t, dur, vol: vol, cutoff: 0.5, attack: 0.6, release: 0.8, highpass: true, seed: 404)
    }
    func clunk(_ t: Double, vol: Double = 0.25) {                    // the searchlight's shutter thrown open
        tone(t, 0.12, 90, to: 50, wave: .square(0.4), vol: vol, decay: 0.05)
        noise(t, 0.08, vol: vol * 0.6, cutoff: 0.3, decay: 0.03, seed: 41)
    }
    func boomTube(_ t: Double, vol: Double = 0.3) {                  // space torn open
        boom(t, vol: vol)
        noise(t, 0.9, vol: vol * 0.5, cutoff: 0.9, decay: 0.3, highpass: true, seed: 66)
        tone(t, 0.8, 1800, to: 120, wave: .saw, vol: vol * 0.25, release: 0.3)
    }
    func buzz(_ t: Double, vol: Double = 0.03) {                     // a Parademon's wings
        tone(t, 0.35, 160 + hashNoise(Int(t * 10)) * 60, wave: .square(0.2), vol: vol, attack: 0.05, release: 0.15, vibrato: 0.1)
    }
    func ice(_ t: Double, vol: Double = 0.08) {                      // Captain Cold's cold gun
        noise(t, 0.3, vol: vol, cutoff: 0.6, attack: 0.02, release: 0.15, highpass: true, seed: Int(t * 97))
        tone(t, 0.3, 3200, to: 2600, wave: .sine, vol: vol * 0.3, release: 0.15)
    }
    func bark(_ t: Double, vol: Double = 0.1) {                      // Krypto, twice
        for k in 0..<2 {
            tone(t + Double(k) * 0.22, 0.12, 520, to: 300, wave: .square(0.35), vol: vol, release: 0.05, decay: 0.06)
            noise(t + Double(k) * 0.22, 0.08, vol: vol * 0.5, cutoff: 0.2, decay: 0.03, seed: k + 12)
        }
    }
}


// Clawd Clash sound effects
extension Mix {
    func scratch(_ t: Double, vol: Double = 0.2) {                   // a record scratch
        tone(t, 0.14, 900, to: 180, wave: .saw, vol: vol, release: 0.03)
        tone(t + 0.14, 0.16, 220, to: 700, wave: .saw, vol: vol * 0.8, release: 0.05)
        noise(t, 0.3, vol: vol * 0.6, cutoff: 0.5, highpass: true, seed: 71)
    }
    func clack(_ t: Double, vol: Double = 0.3) {                     // the slate snapping shut
        noise(t, 0.05, vol: vol, cutoff: 0.95, decay: 0.012, highpass: true, seed: Int(t * 37))
        tone(t, 0.06, 380, to: 160, wave: .square(0.5), vol: vol * 0.5, decay: 0.02)
    }
    func recordStop(_ t: Double, vol: Double = 0.12) { tone(t, 0.6, 500, to: 40, wave: .saw, vol: vol, release: 0.2) }
    func slideWhistle(_ t: Double, up: Bool, vol: Double = 0.07) {
        tone(t, 0.5, up ? 500 : 1500, to: up ? 1500 : 500, wave: .sine, vol: vol, attack: 0.03, release: 0.08, vibrato: 0.01)
    }
    func wahWah(_ t: Double, vol: Double = 0.07) {                   // the sad trombone, four notes down
        for (k, n) in [58, 57, 56, 55].enumerated() {
            let d = k == 3 ? 0.9 : 0.28
            tone(t + Double(k) * 0.3, d, midi(n), to: midi(n) * 0.97, wave: .saw, vol: vol, attack: 0.03, release: 0.1, vibrato: k == 3 ? 0.03 : 0.01)
        }
    }
    func shimmer(_ t: Double, _ dur: Double, vol: Double = 0.03) {   // something magic floating up
        var s = 0.0, k = 0
        while s < dur { tone(t + s, 0.25, midi([84, 88, 91, 96][k % 4]), wave: .sine, vol: vol, release: 0.2, decay: 0.12); s += 0.12; k += 1 }
    }
    func applause(_ t: Double, _ dur: Double, vol: Double = 0.06) {
        for i in 0..<Int(dur * 40) { noise(t + Double(i) / 40 + hashNoise(i) * 0.02, 0.03, vol: vol, cutoff: 0.7, decay: 0.01, highpass: true, seed: i + 900) }
    }
}

/// Sounds of the transition that brings in shot `s`.
func transitionSound(_ m: Mix, _ s: Shot) {
    let d = s.into.duration, t0 = s.start - d / 2
    switch s.into {
    case .cut: break
    case .wipe, .starWars: m.whoosh(s.start, d, vol: 0.08)
    case .marvel(let trip):
        switch trip.kind {
        case .burst: m.boom(t0 + d * 0.3, vol: 0.25); m.snare(t0 + d * 0.3, vol: 0.12)
        case .speedLines: m.whoosh(s.start, d, vol: 0.14)
        default: m.whoosh(s.start, d, vol: 0.08)
        }
    case .dc(let trip):
        switch trip.kind {
        case .batSignal: m.clunk(t0 + d * 0.35); m.boom(t0 + d * 0.5, vol: 0.2)
        case .grapple: m.thwip(t0 + d * 0.15, vol: 0.12); m.whoosh(t0 + d * 0.5, d * 0.5, vol: 0.1)
        case .jokerCard: m.flip(t0 + d * 0.2, vol: 0.1); m.slideWhistle(t0 + d * 0.45, up: true)
        default: m.whoosh(s.start, d, vol: 0.08)
        }
    case .middleEarth(let trip):
        switch trip.kind {
        case .fireworks:   // the rocket whistling up, the bang, and the sparks crackling as they fall
            m.tone(t0 + d * 0.04, d * 0.24, 700, to: 2400, wave: .sine, vol: 0.05, attack: 0.05, release: 0.05)
            m.noise(t0 + d * 0.04, d * 0.24, vol: 0.04, cutoff: 0.8, attack: 0.05, release: 0.05, highpass: true, seed: 71)
            m.boom(t0 + d * 0.28, vol: 0.4); m.noise(t0 + d * 0.28, 0.8, vol: 0.12, cutoff: 0.9, decay: 0.3, highpass: true, seed: 72)
            m.crackle(t0 + d * 0.32, d * 0.6, vol: 0.04)
        default:
            m.tone(t0 + d * 0.3, d * 0.5, 55, to: 40, wave: .saw, vol: 0.06, attack: 0.1, release: 0.3); m.boom(t0 + d * 0.55, vol: 0.18)
        }
    case .trip(let trip):
        if let dt = trip.trip as? DoctorTrip, dt.kind == .dematerialise { m.wheeze(t0 + d * 0.05, cycles: Int(d / 0.62), vol: 0.1) }
        else { m.whoosh(s.start, d, vol: 0.12) }
    }
}

func start(_ name: String) -> Double { shots.first { $0.name == name }!.start }
func end(_ name: String) -> Double { shots.first { $0.name == name }!.end }

/// The chiptune groove (Am F C G), on its own track and faded in from `from` over `fadeIn` seconds.
func groove(_ m: Mix, from g0: Double, to g1: Double, fadeIn: Double) {
    let gm = Mix(seconds: duration), beat = 0.5, bar = 2.0
    let roots = [45, 41, 48, 43], triads = [[69, 72, 76], [65, 69, 72], [67, 72, 76], [67, 71, 74]]
    let melodyA: [[(Int, Double)]] = [[(76, 1), (81, 1), (84, 0.5), (83, 0.5), (81, 1)], [(84, 1), (81, 1), (77, 0.5), (79, 0.5), (81, 1)],
                                      [(79, 1), (76, 0.5), (79, 0.5), (84, 1), (83, 1)], [(86, 1), (83, 1), (79, 2)]]
    let melodyB: [[(Int, Double)]] = [[(81, 0.5), (84, 0.5), (88, 1), (86, 0.5), (84, 0.5), (83, 1)], [(81, 1.5), (84, 0.5), (81, 1), (77, 1)],
                                      [(79, 0.5), (81, 0.5), (79, 0.5), (76, 0.5), (79, 1), (84, 1)], [(83, 1), (86, 1), (91, 2)]]
    let bars = Int(((g1 - g0) / bar).rounded())
    for b in 0..<bars {
        let t0 = g0 + Double(b) * bar, c = b % 4, full = b >= 2
        for e in 0..<8 {
            gm.tone(t0 + Double(e) * beat / 2, beat / 2 * 0.9, midi(roots[c] - 12 + (e % 2) * 12), wave: .square(0.25), vol: full ? 0.075 : 0.05, release: 0.02)
            gm.hat(t0 + Double(e) * beat / 2, vol: e % 2 == 1 ? 0.04 : 0.025)
        }
        gm.kick(t0)
        if full {
            gm.kick(t0 + 2 * beat); gm.kick(t0 + 2.5 * beat, vol: 0.18); gm.snare(t0 + beat); gm.snare(t0 + 3 * beat)
            for s in 0..<16 { gm.tone(t0 + Double(s) * beat / 4, beat / 4 * 0.8, midi(triads[c][s % 3] - 12 + (s / 3 % 2) * 12), wave: .triangle, vol: 0.03, release: 0.02) }
            var tt = t0
            for (n, d) in ((b - 2) / 4 % 2 == 0 ? melodyA : melodyB)[c] { gm.tone(tt, d * beat * 0.92, midi(n), wave: .square(0.5), vol: 0.055, release: 0.04, vibrato: 0.004); tt += d * beat }
        }
        if b == bars - 1 { for k in 0..<8 { gm.snare(t0 + 2 * beat + Double(k) * beat / 4, vol: 0.06 + Double(k) * 0.01) } }
    }
    for i in gm.buf.indices where gm.buf[i] != 0 {
        let t = Double(i) / sampleRate
        m.buf[i] += gm.buf[i] * Float(clamp((t - g0 + fadeIn * 0.5) / fadeIn))
    }
}

// Sound effects more than one reel uses
extension Mix {
    /// The TARDIS: a grinding wheeze rising and falling, `cycles` times.
    func wheeze(_ t: Double, cycles: Int, vol: Double = 0.1) {
        for k in 0..<cycles {
            let s = t + Double(k) * 0.62
            noise(s, 0.6, vol: vol, cutoff: 0.02, cutoffTo: 0.25, attack: 0.25, release: 0.3, seed: 40 + k)
            tone(s, 0.3, 110, to: 190, wave: .saw, vol: vol * 0.45, attack: 0.12, release: 0.05)
            tone(s + 0.3, 0.32, 190, to: 105, wave: .saw, vol: vol * 0.45, attack: 0.03, release: 0.18)
            tone(s, 0.6, 330, to: 360, wave: .sine, vol: vol * 0.3, attack: 0.2, release: 0.3, vibrato: 0.04)
        }
    }
    /// A typewriter: a key for every letter, `n` of them `gap` apart, and the bell if `bell`.
    func typewriter(_ t: Double, _ n: Int, gap: Double = 0.05, vol: Double = 0.08, bell: Bool = false) {
        for i in 0..<n { noise(t + Double(i) * gap + renderpromo.noise(i * 13) * 0.01, 0.03, vol: vol, cutoff: 0.6, decay: 0.01, highpass: true, seed: 700 + i) }
        if bell { tone(t + Double(n) * gap + 0.05, 0.6, 2093, wave: .sine, vol: 0.04, release: 0.5, decay: 0.3) }
    }
}

/// The reel's soundtrack: `score` writes it into a mix as long as the reel, then it's softly limited, brought up to
/// just under full scale and faded out over the last 1.2 s.
func soundtrack(_ score: (Mix) -> Void) -> [Float] {
    let m = Mix(seconds: duration)
    score(m)
    var peak: Float = 0
    for i in m.buf.indices { m.buf[i] = Float(tanh(Double(m.buf[i]) * 1.2)); peak = max(peak, abs(m.buf[i])) }
    let gain = peak > 0 ? 0.89 / peak : 1
    let fadeFrom = Int((duration - 1.2) * sampleRate)
    for i in m.buf.indices {
        m.buf[i] *= gain
        if i > fadeFrom { m.buf[i] *= Float(max(0, 1 - Double(i - fadeFrom) / (1.2 * sampleRate))) }
    }
    return m.buf
}
