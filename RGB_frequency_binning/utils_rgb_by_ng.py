import plotly.graph_objects as go
import torch
from plotly.subplots import make_subplots

from RGB_frequency_binning.utils_other import rescale_range


def rgb_by_neural_gas_b_is_dc_hist(
    fft: torch.Tensor,
    freqs: torch.Tensor,
    n_epochs: int,
    init_lr: float = 1.0,
    end_lr: float = 1e-3,
    rel_inti_rad: float = 0.5,
    end_rad: float = 0.01,
    make_plots: bool = False,
    display_plots: bool = False,
) -> tuple[torch.Tensor, go.Figure]:
    """Neural gas clustering to perform RGB frequency binning.

    Args:
        fft (torch.Tensor): Positive side of the FFT.
        freqs (torch.Tensor): Corresponding frequencies.
        n_epochs (int): Number of epochs to run.
        init_lr (float, optional): Initial learning rate. Defaults to 1.0.
        end_lr (float, optional): End learning rate to converge to. Defaults to 1e-3.
        rel_inti_rad (float, optional): Initial neighborhood radius. Defaults to 0.5.
        end_rad (float, optional): End neighborhood radius to converge to. Defaults to 0.01.
        make_plots (bool, optional): If spectral clustering plots should be saved. Defaults to False.
        display_plots (bool, optional): If spectral clustering plots should also be shown. Defaults to False.

    Returns:
        tuple[torch.Tensor, go.Figure]: RGB frequency binned image and spectral plots.
    """
    # Sum spectra
    fft_sum: torch.Tensor = torch.sum(fft, dim=-1)
    while fft_sum.ndim > 1:
        fft_sum = torch.sum(fft_sum, dim=-1)

    # Remove 0 freq
    fft_sum_no_dc: torch.Tensor = torch.clone(fft_sum[1:]).type_as(fft_sum)
    fft_sum_no_dc = rescale_range(fft_sum_no_dc, new_min=1e-3, new_max=1.0)
    freqs_no_dc: torch.Tensor = torch.clone(freqs[1:]).type_as(fft_sum)

    # Create Nx2 matrix with frequency bins and corresponding amplitudes
    samples: torch.Tensor = torch.transpose(
        torch.stack([freqs_no_dc, fft_sum_no_dc]), 0, 1
    )

    # Find R & G frequency cluster
    freq_cluster: torch.Tensor = torch.squeeze(
        neural_gas_hist(
            samples,
            codebook_size=2,
            n_epochs=n_epochs,
            init_lr=init_lr,
            end_lr=end_lr,
            init_radius=freqs.size(dim=0) * rel_inti_rad,
            end_radius=end_rad,
            return_full_history=make_plots,
        )
    )  # Epochs x 2

    # Figure for plots
    fig_freq_clusts: go.Figure = make_subplots(
        rows=1,
        cols=3,
        shared_yaxes=True,
        subplot_titles=(
            "Neural Gas convergence",
            "Normalized spectrum",
            "Actual spectrum",
        ),
    )
    if make_plots:
        fig_freq_clusts.update_layout(
            showlegend=False,
            title_text=f"Neural Gas with {n_epochs} Epochs",
            title_x=0.5,
            yaxis_title="Frequency (Hz)",
        )
        fig_freq_clusts.update_xaxes(title_text="Epochs", row=1, col=1)
        fig_freq_clusts.update_xaxes(title_text="Normalized Amplitudes", row=1, col=2)
        fig_freq_clusts.update_xaxes(title_text="Summed Amplitudes", row=1, col=3)

        # Plot green & red cluster history
        green_clust_hist: torch.Tensor = freq_cluster[
            :, torch.argmin(freq_cluster[-1, :])
        ]
        red_clust_hist: torch.Tensor = freq_cluster[
            :, torch.argmax(freq_cluster[-1, :])
        ]

        fig_freq_clusts.append_trace(
            go.Scatter(
                y=green_clust_hist.detach().cpu().numpy(),
                mode="markers",
                marker={"color": "green"},
            ),
            row=1,
            col=1,
        )
        fig_freq_clusts.append_trace(
            go.Scatter(
                y=red_clust_hist.detach().cpu().numpy(),
                mode="markers",
                marker={"color": "red"},
            ),
            row=1,
            col=1,
        )
        fig_freq_clusts.update_yaxes(range=(torch.min(freqs), torch.max(freqs)))

        freq_cluster = freq_cluster[-1, :]

    red_cluster: float = float(torch.max(freq_cluster))
    green_cluster: float = float(torch.min(freq_cluster))
    blue_cluster: float = 0.0

    green_cutoff: float = (green_cluster + red_cluster) / 2
    blue_cutoff: float = blue_cluster

    # Get index from frequencies:
    red_idx: torch.Tensor = freqs > green_cutoff
    green_idx: torch.Tensor = torch.logical_and(
        freqs > blue_cutoff, freqs <= green_cutoff
    )
    blue_idx: torch.Tensor = freqs <= blue_cutoff

    # Get actual cutoff frequencies:
    blue_freq_min: float = float(torch.min(freqs[blue_idx]))
    blue_freq_max: float = float(torch.max(freqs[blue_idx]))
    red_freq_min: float = float(torch.min(freqs[red_idx]))
    red_freq_max: float = float(torch.max(freqs[red_idx]))
    green_freq_min: float = float(torch.min(freqs[green_idx]))
    green_freq_max: float = float(torch.max(freqs[green_idx]))

    print(
        f"B: {blue_freq_min} - {blue_freq_max}, "
        f"G: {green_freq_min} - {green_freq_max}, "
        f"R: {red_freq_min} - {red_freq_max}"
    )

    if make_plots:
        # Plot spectrum used for NG by final clustering (No DC)
        fig_freq_clusts.append_trace(
            go.Bar(
                x=fft_sum_no_dc[green_idx[1:]].detach().cpu().numpy(),
                y=freqs[1:][green_idx[1:]].detach().cpu().numpy(),
                orientation="h",
                marker_color="green",
            ),
            row=1,
            col=2,
        )
        fig_freq_clusts.append_trace(
            go.Bar(
                x=fft_sum_no_dc[red_idx[1:]].detach().cpu().numpy(),
                y=freqs[1:][red_idx[1:]].detach().cpu().numpy(),
                orientation="h",
                marker_color="red",
            ),
            row=1,
            col=2,
        )

        # Plot actual spectrum by final clustering
        fig_freq_clusts.append_trace(
            go.Bar(
                x=fft_sum[blue_idx].detach().cpu().numpy(),
                y=freqs[blue_idx].detach().cpu().numpy(),
                orientation="h",
                marker_color="blue",
            ),
            row=1,
            col=3,
        )
        fig_freq_clusts.append_trace(
            go.Bar(
                x=fft_sum[green_idx].detach().cpu().numpy(),
                y=freqs[green_idx].detach().cpu().numpy(),
                orientation="h",
                marker_color="green",
            ),
            row=1,
            col=3,
        )
        fig_freq_clusts.append_trace(
            go.Bar(
                x=fft_sum[red_idx].detach().cpu().numpy(),
                y=freqs[red_idx].detach().cpu().numpy(),
                orientation="h",
                marker_color="red",
            ),
            row=1,
            col=3,
        )

        if display_plots:
            fig_freq_clusts.show()

    img_size = list(fft.size())
    img_size[0] = 3  # Exchange
    dynamic: torch.Tensor = torch.zeros(tuple(img_size)).type_as(fft)  # 3xYxX
    dynamic[0, ...] = torch.sum(fft[red_idx, ...], dim=0)
    dynamic[1, ...] = torch.sum(fft[green_idx, ...], dim=0)
    dynamic[2, ...] = torch.sum(fft[blue_idx, ...], dim=0)

    return dynamic, fig_freq_clusts


def neural_gas_hist(
    samples: torch.Tensor,
    codebook_size: int,
    n_epochs: int,
    init_lr: float,
    end_lr: float,
    init_radius: float,
    end_radius: float,
    return_full_history: bool = False,
) -> torch.Tensor:
    """Neural gas clustering.

    Args:
        samples (torch.Tensor): Tensor of shape nr samples x sample dimensions
        codebook_size (int): Number of clusters to use.
        n_epochs (int): Number of epochs to run.
        init_lr (float): Initial learning rate.
        end_lr (float): End learning rate to converge to.
        init_radius (float): Initial neighborhood radius.
        end_radius (float): End neighborhood radius to converge to.
        return_full_history (bool, optional): If the cluster positions for all epochs are to be returned or just the final result. Defaults to False.

    Returns:
        torch.Tensor: Tensor containing the cluster positions of shape Epochs X codebook_size or just codebook_size depending on return_full_history.
    """
    # Norm Y values to [1e-3, 1]
    samples[:, 1] = rescale_range(samples[:, 1], new_min=1e-3, new_max=1.0)

    n_samples: int = samples.shape[0]

    codebook_vectors: torch.Tensor = rescale_range(
        torch.rand(
            (codebook_size, 1),
        ),
        float(torch.min(samples)),
        float(torch.max(samples)),
    ).type_as(samples)

    all_cvs: list[torch.Tensor] = [codebook_vectors]

    for epoch in range(n_epochs):
        ep_power: float = epoch / n_epochs
        learning_rate: float = init_lr * (end_lr / init_lr) ** ep_power
        neighborhood_radius: float = (
            init_radius * (end_radius / init_radius) ** ep_power
        )
        indexes: torch.Tensor = torch.randperm(n_samples)

        for index in indexes:
            sample: torch.Tensor = samples[index]  # n_features

            # Euclidean distances between sample and each codebook vector
            distances: torch.Tensor = torch.norm(
                sample[0] - codebook_vectors, dim=1
            )  # codebook_size x n_features

            # Compute the rank of each codebook vector
            ranks: torch.Tensor = torch.argsort(distances)

            # Update all codebook vectors
            # Amplitude is multiplied as a weight
            codebook_vectors = codebook_vectors + learning_rate * sample[1] * torch.exp(
                -ranks / neighborhood_radius
            )[:, None] * (sample[0] - codebook_vectors)

        if return_full_history:
            all_cvs.append(codebook_vectors)

    if return_full_history:
        return torch.stack(all_cvs)
    else:
        return codebook_vectors
