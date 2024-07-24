using Printf
using Glob
using CairoMakie
using FFMPEG_jll

x = -π:0.01:π
y = -2:0.01:2

k = 2
ω = 1

Nf = 200
for n in 1:Nf
    t = n/Nf * 10
    f = @. exp(-abs(y' - sin(k*x - ω*t))) + 0.5*(1-(n/Nf)^2)*randn()

    fig = Figure(size = (600, 400))
    ax = Axis(fig[1, 1]; xlabel = "x", ylabel = "y")
    hmap = heatmap!(ax, x, y, f, colorrange=(0, 1))
    Colorbar(fig[1, 2], hmap)
    
    @info "Saving frame $n"
    save(@sprintf("frame%06d.png", n), fig)
end

FFMPEG_jll.ffmpeg() do exe
    run(`$exe -y -framerate 30 -i frame%06d.png -c:v libx264 -pix_fmt yuv420p test.mp4`)
end

rm.(glob("frame*.png"))

