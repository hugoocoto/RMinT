# Rolling Min Tree: Max or Pass

The Rolling Min Tree (RMinT) finds the $K$ largest elements of a vector of $N$
values using a fixed-capacity min-heap of size $K$. It costs $O(N \log K)$ in
the worst case and uses $O(K)$ memory.

## Paper

The latest PDFs are built from `main` and published automatically:

- [English](https://github.com/hugoocoto/RMinT/releases/download/latest/paper_en.pdf)
- [Spanish](https://github.com/hugoocoto/RMinT/releases/download/latest/paper.pdf)

## Build

Building requires [Typst](https://typst.app) 0.15.1 and the TeX Gyre fonts.

```sh
typst compile main_en.typ paper_en.pdf
typst compile main.typ paper.pdf
```

## Citation

```bibtex
@misc{cotoflorez2026rmint,
  author       = {Coto Fl{\'o}rez, Hugo and Sanchez Miguez, David},
  title        = {{Rolling Min Tree}: Max or Pass},
  year         = {2026},
  howpublished = {GitHub repository},
  url          = {https://github.com/hugoocoto/RMinT}
}
```

## License

[MIT](LICENSE)
