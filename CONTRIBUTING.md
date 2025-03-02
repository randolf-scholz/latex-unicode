# Contributing

Make sure your code passes pre-commit checks before submitting a pull request.

```bash
pre-commit install
pre-commit run -a
```

## Unit tests

The `tests/` folder contains several sample documents that need to compile without errors.
The test suite can be run using [`just`](https://github.com/casey/just).

```bash
just test
```
