using Printf
using Glob
using CairoMakie
using FFMPEG_jll

using Base.Threads: @threads, threadid

x = -π:0.01:π
y = -2:0.01:2

k = 2
ω = 1

function save_frame(n, Nf)
    t = n/Nf * 100
    f = @. exp(-abs(y' - sin(k*x - ω*t))) + (1-sqrt(n/Nf))*randn()

    fig = Figure(size = (600, 400))
    ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y")
    hmap = heatmap!(ax, x, y, f)
    
    @info "Thread $(threadid()):  Saving frame $n"
    save(@sprintf("frame%06d.png", n), fig)

    return nothing
end

function main()
    Nf = 2000
    @threads for n in 1:Nf
        save_frame(n, Nf)
    end

    return nothing
end

main()

FFMPEG_jll.ffmpeg() do exe
    run(`$exe -y -framerate 30 -i frame%06d.png -c:v libx264 -pix_fmt yuv420p test.mp4`)
end

rm.(glob("frame*.png"))
