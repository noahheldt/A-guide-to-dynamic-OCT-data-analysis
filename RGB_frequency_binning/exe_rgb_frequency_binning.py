import pathlib

import numpy as np
import plotly.graph_objects as go
import tifffile
import torch

from RGB_frequency_binning.utils_other import (
    check_mkdir,
    hist_matching,
    normalize_and_expand_channels,
    rescale_range,
    saturate_values,
    save_uint8,
)
from RGB_frequency_binning.utils_rgb_by_ng import rgb_by_neural_gas_b_is_dc_hist


def rgb_frequency_binning(
    in_file: pathlib.Path,
    out_folder: pathlib.Path,
    fps: float,
    linearize: bool = True,
):
    """Default RGB frequency binning.

    Args:
        in_file (pathlib.Path): tiff file containing registered data of shape TxHxW.
        out_folder (pathlib.Path): Folder to save results into.
        fps (float): Frames per second of the in_file data. Though, this is just for plotting purposes and can otherwise arbitrarily be chosen if unsure.
        linearize (bool, optional): If in_file data is logarithmic. Defaults to True.
    """
    # Load file
    img: torch.Tensor = torch.from_numpy(
        tifffile.imread(in_file).astype(np.float32)
    )  # TxHxW

    # Linearize dB data if needed
    if linearize:
        img = 10 ** (img / 20)

    time_res: float = 1 / fps

    # Logarithmic standard deviation per pixel
    std: torch.Tensor = torch.log10(torch.std(img, dim=0))  # HxW

    # FFT over time axis (for each pixel) and discard negative spectrum
    nr_frames: int = img.size(0)
    pos_side: int = nr_frames // 2 + 1
    fft: torch.Tensor = torch.abs(torch.fft.fft(img, dim=0))[:pos_side, ...]
    freqs: torch.Tensor = torch.abs(
        torch.fft.fftfreq(nr_frames, time_res)[:pos_side, ...]
    )

    # Bin frequencies to RGB
    dynamic: torch.Tensor
    fig: go.Figure
    dynamic, fig = rgb_by_neural_gas_b_is_dc_hist(
        fft,
        freqs,
        n_epochs=10,
        init_lr=0.1,
        rel_inti_rad=0.1,
        make_plots=True,
        display_plots=False,
    )
    save_path: pathlib.Path = out_folder.joinpath(f"{in_file.stem}-spectrum.jpg")
    fig.write_image(save_path, scale=3.0)

    for i in range(3):
        # Saturate top 0.01 and bottom 0.1 percent of unique values
        dynamic[i, ...] = saturate_values(dynamic)

        dynamic[i, ...] = rescale_range(dynamic[i, ...])

    std = normalize_and_expand_channels(std)
    dynamic = hist_matching(dynamic, std)

    save_path: pathlib.Path = out_folder.joinpath(f"{in_file.stem}-dyn-NG.png")
    save_uint8(dynamic, save_path)


if __name__ == "__main__":
    in_file: pathlib.Path = pathlib.Path(r"C:\foo\bar.tiff")

    fps: float = 100  # Hz
    linearize: bool = True  # True if dB data is used

    out_folder: pathlib.Path = in_file.parent.joinpath("NG")
    check_mkdir(out_folder)

    rgb_frequency_binning(in_file, out_folder, fps, linearize)
