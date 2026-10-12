$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Drawing

$assetDirectory = Join-Path (Split-Path $PSScriptRoot -Parent) 'NumismaticsDex.App\Assets'
New-Item -Path $assetDirectory -ItemType Directory -Force | Out-Null

foreach ($asset in @(
    @{ Name = 'Square150x150Logo.png'; Size = 150 },
    @{ Name = 'Square44x44Logo.png'; Size = 44 },
    @{ Name = 'StoreLogo.png'; Size = 50 }
)) {
    $bitmap = [System.Drawing.Bitmap]::new($asset.Size, $asset.Size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $coinBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(39, 107, 85))
    $letterBrush = [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(255, 255, 255))
    $borderPen = [System.Drawing.Pen]::new([System.Drawing.Color]::FromArgb(168, 79, 53), [Math]::Max(1, [int]($asset.Size * 0.04)))
    $font = [System.Drawing.Font]::new('Georgia', [single]($asset.Size * 0.48), [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
    $format = [System.Drawing.StringFormat]::new()

    try {
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $graphics.Clear([System.Drawing.Color]::FromArgb(241, 244, 240))
        $inset = [single]($asset.Size * 0.1)
        $coinBounds = [System.Drawing.RectangleF]::new($inset, $inset, $asset.Size - 2 * $inset, $asset.Size - 2 * $inset)
        $graphics.FillEllipse($coinBrush, $coinBounds)
        $graphics.DrawEllipse($borderPen, $coinBounds)
        $format.Alignment = [System.Drawing.StringAlignment]::Center
        $format.LineAlignment = [System.Drawing.StringAlignment]::Center
        $graphics.DrawString('N', $font, $letterBrush, [System.Drawing.RectangleF]::new(0, 0, $asset.Size, $asset.Size), $format)
        $bitmap.Save((Join-Path $assetDirectory $asset.Name), [System.Drawing.Imaging.ImageFormat]::Png)
    }
    finally {
        $format.Dispose()
        $font.Dispose()
        $borderPen.Dispose()
        $letterBrush.Dispose()
        $coinBrush.Dispose()
        $graphics.Dispose()
        $bitmap.Dispose()
    }
}