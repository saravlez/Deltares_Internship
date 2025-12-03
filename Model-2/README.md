



## Large Files Notice

This repository (in particular, folder data and data_multiscale) uses **Git Large File Storage (Git LFS)** to manage datasets
(e.g. `.jld2` files) that exceed GitHub’s 100 MB file size limit.

### What this means for you
- Before cloning or pulling, make sure you have Git LFS installed:
  - **macOS**: `brew install git-lfs`
  - **Linux**: use your package manager (e.g. `sudo apt install git-lfs`)
  - **Windows**: download from [https://git-lfs.github.com](https://git-lfs.github.com)

- Initialize Git LFS once:
  ```bash
  git lfs install
  ```
- When you clone this repo, Git will fetch lightweight pointer files. To download the actual large files, run:
  ```
  git lfs pull
  ```
