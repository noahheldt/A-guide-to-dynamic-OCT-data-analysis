import pathlib

import torch
import torchvision
from skimage.exposure import match_histograms


def check_mkdir(directory_or_file: pathlib.Path, exists_ok: bool = True) -> None:
    """Create a directory for the give path if none exists.

    Args:
        directory_or_file (pathlib.Path): Path to an existing or new directory.
    """
    directory: pathlib.Path = get_directory(directory_or_file)
    directory.mkdir(parents=False, exist_ok=exists_ok)


def get_directory(directory_or_file: pathlib.Path) -> pathlib.Path:
    """Get the directory of a path.

    Args:
        directory_or_file (pathlib.Path): Path to either a file or directory

    Returns:
        pathlib.Path: Directory of the path.
    """
    directory: pathlib.Path

    if directory_or_file.is_file():
        directory = directory_or_file.parent
    else:
        directory = directory_or_file

    return directory


def rescale_range(
    in_arr: torch.Tensor, new_min: float = 0.0, new_max: float = 1.0
) -> torch.Tensor:
    """Rescale the range of a given array to the new min and max.

    Args:
        in_arr (torch.Tensor): Input array to rescale the range of.
        new_min (float): New minimum. Defaults to 0.
        new_max (float): New maximum. Defaults to 1.

    Returns:
        torch.Tensor: Range rescaled array.
    """
    old_min: float = float(torch.min(in_arr))
    old_max: float = float(torch.max(in_arr))

    in_arr = (in_arr - old_min) / (old_max - old_min) * (new_max - new_min) + new_min

    return in_arr


def normalize_and_expand_channels(arr: torch.Tensor, dims: int = 3) -> torch.Tensor:
    """Normalizes input to [0, 1] and multiplies it into dims channels.

    Args:
        arr (torch.Tensor): Input to normalize and expand
        dims (int, optional): Amount of expansions. Defaults to 3.

    Returns:
        torch.Tensor: Normalized tensor of shape dims x H x W.
    """
    # Normalize to [0, 1]
    arr = rescale_range(arr)

    # Expand to CxHxW
    arr_channels: torch.Tensor = torch.repeat_interleave(arr[None, ...], dims, dim=0)

    return arr_channels


def saturate_values(
    img: torch.Tensor, clip_top: float = 0.9999, clip_bottom: float = 0.001
) -> torch.Tensor:
    """Clips values of an input to the given upper and lower percentages.

    Args:
        img (torch.Tensor): Input tensor to clip.
        clip_top (float, optional): Upper clip limit. Defaults to 0.9999 (0.01 %).
        clip_bottom (float, optional): Lower clip limit. Defaults to 0.001 (0.1 %).

    Returns:
        torch.Tensor: Clipped Tensor.
    """
    unique_vals: torch.Tensor = torch.unique(img)

    # Clip top values
    sat_limit = float(torch.max(unique_vals[: int(unique_vals.size(0) * clip_top)]))
    img[img > sat_limit] = sat_limit

    # Clip bottom values
    sat_limit = float(torch.min(unique_vals[int(unique_vals.size(0) * clip_bottom) :]))
    img[img < sat_limit] = sat_limit

    return img


def hist_matching(img1: torch.Tensor, img2: torch.Tensor) -> torch.Tensor:
    """Channel wise histogram matching of img1 onto the histogram of img2.

    Args:
        img1 (torch.Tensor): Tensor whose histogram is to be adjusted.
        img2 (torch.Tensor): Tensor to use as target histogram

    Returns:
        torch.Tensor: Histogram matched output
    """
    # This is 1 for all non-empty channels and 0 for all empty channels.
    max_vals: torch.Tensor = torch.max(img1.reshape(img1.size(0), -1), dim=-1)[0]

    out_img: torch.Tensor = torch.from_numpy(
        match_histograms(
            img1.detach().cpu().numpy(), img2.detach().cpu().numpy(), channel_axis=0
        )
    ).type_as(img1)

    # Zero previously empty channels again (they get set to 1 by match_histograms)
    while max_vals.ndim < out_img.ndim:
        max_vals = torch.unsqueeze(max_vals, dim=-1)
    out_img *= max_vals

    return out_img


def save_uint8(img: torch.Tensor, path: pathlib.Path) -> None:
    """Save input as uint8 file to the given path.

    Args:
        img (torch.Tensor): [0, 1] normalized image.
        path (pathlib.Path): Path to save to, including the suffix.
    """
    torchvision.utils.save_image(img[None, ...].detach().cpu(), path)
