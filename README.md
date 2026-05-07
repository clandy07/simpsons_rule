# Simpson's Rule — Shiny App

An interactive R Shiny app that approximates definite integrals using the **composite Simpson's 1/3 Rule**, visualizes the area under the curve, and shows every step of the calculation.

$$
S_n = \frac{\Delta x}{3}\Big[f(x_0) + 4f(x_1) + 2f(x_2) + 4f(x_3) + 2f(x_4) + \cdots + 2f(x_{n-2}) + 4f(x_{n-1}) + f(x_n)\Big],
\qquad \Delta x = \frac{b-a}{n}
$$

The error bound is

$$
\bigl|\,\text{Error in } S_n\,\bigr| \;\le\; \frac{M\,(b-a)^5}{180\,n^4},
$$

where $M$ is the maximum of $|f^{(4)}(x)|$ on $[a, b]$.

> $n$ (the number of subintervals) **must be even**.

---

## Project Structure

```
simpsons_rule/
├── ui.R         # UI: layout, styling, tabs, inputs, outputs
├── server.R     # Server: validation, Simpson's Rule math, plot, table, steps
└── README.md    # You are here
```

This is a standard two-file Shiny app. R/Shiny auto-detects `ui.R` and `server.R` in the same folder — there is no `app.R`.

---

## Prerequisites (Windows)

1. **R** (≥ 4.0) — download the installer from <https://cloud.r-project.org/bin/windows/base/> and run it with the default options.
   - This installs both `R.exe` and `Rscript.exe` under `C:\Program Files\R\R-<version>\bin\`.
   - During install, leave **"Save version number in registry"** checked so other tools can find R.
2. **Rtools** (only needed if a package ever has to compile from source) — <https://cran.r-project.org/bin/windows/Rtools/>. Not required for `shiny` or `DT`, but harmless to install.
3. **R packages** — only two:
   - `shiny`
   - `DT`

Install the packages once. Open **PowerShell** (or **Command Prompt**) and run:

```powershell
Rscript -e "install.packages(c('shiny','DT'), repos='https://cloud.r-project.org')"
```

If `Rscript` is not recognized, either:
- add `C:\Program Files\R\R-<version>\bin` to your **PATH** (System Properties → Environment Variables), or
- run the full path: `"C:\Program Files\R\R-<version>\bin\Rscript.exe" -e "install.packages(...)"`.

No other packages are required. The app uses base R's `integrate()` for the "true" value and pure base R for the Simpson's Rule computation (no `pracma`, `caTools`, etc.).

---

## Running the App (Windows)

### Option A — RStudio (easiest)

1. Install **RStudio Desktop** (free) from <https://posit.co/download/rstudio-desktop/>.
2. **File → Open Project** … or just **File → Open Folder** and pick the `simpsons_rule` folder.
3. Open `ui.R` or `server.R` in the editor.
4. Click the green **▶ Run App** button in the top-right of the editor pane.

The app opens in a built-in browser window. Stop it with the red stop button.

### Option B — VS Code with the Shiny extension

1. Install **VS Code** from <https://code.visualstudio.com/>.
2. Install these extensions from the Extensions panel:
   - **R** (`reditorsupport.r`)
   - **Shiny** (`posit.shiny`)
3. *(Optional but recommended)* In R, install the language-server helper:
   ```powershell
   Rscript -e "install.packages('languageserver', repos='https://cloud.r-project.org')"
   ```
4. **File → Open Folder…** and pick the `simpsons_rule` folder.
5. Open `ui.R` or `server.R`. Click the **▷ Run Shiny App** button in the editor's top-right corner.

The app opens in VS Code's Simple Browser. Edits to `ui.R` / `server.R` hot-reload automatically (devmode).

### Option C — PowerShell / Command Prompt

```powershell
cd "C:\path\to\simpsons_rule"
Rscript -e "shiny::runApp('.', launch.browser = TRUE)"
```

The app serves on `http://127.0.0.1:<port>` and opens in your default browser. Press **Ctrl+C** in the terminal to stop it.

---

## Using the App

1. **Introduction tab** — Definition of Simpson's Rule, the formula, applications, and a cheatsheet of how to write functions in R.
2. **Calculate tab — Sidebar inputs:**
   - `Function f(x)` — written in R syntax (e.g. `x^3 + 2*x`, `sin(x)`, `exp(-x^2)`).
   - `Lower bound a`, `Upper bound b`.
   - `Number of subintervals n` — must be **even**.
3. **Calculate tab — Right side (nested tabs):**
   - **Plot** — the curve over `[a, b]` with the approximated area shaded blue and the subinterval nodes marked.
   - **Steps** — one box per node showing `x_i`, `f(x_i)`, the Simpson coefficient (`1`, `4`, or `2`), and the weighted term, plus a final box with the full summation.
   - **Table** — a `DT` table with columns `i, x_i, f(x_i), Coefficient, Weighted Value`.
4. Below the sidebar: the approximated integral, the true value (via `integrate()`), and the absolute error.

### R function formatting

Use R syntax — implicit multiplication is **not** allowed.

| Instead of | Write       |
| ---------- | ----------- |
| `2x`       | `2*x`       |
| `sin^2(x)` | `sin(x)^2`  |
| `logx`     | `log10(x)`  |
| `logn(x)`  | `log(x)`    |
| `expx`     | `exp(x)`    |
| `absx`     | `abs(x)`    |

---

## Validation Rules

The app shows a friendly message instead of crashing when:

- the function field is empty or the expression cannot be parsed/evaluated,
- `a` or `b` is not a finite number,
- `b <= a`,
- `n` is not a positive integer ≥ 2,
- `n` is **odd** → *"n must be an even number for Simpson's Rule"*.

---

## Development Notes

### How the math is implemented (`server.R`)

A single reactive, `df_results()`, returns a data frame with one row per node:

| column        | meaning                                              |
| ------------- | ---------------------------------------------------- |
| `i`           | node index, `0..n`                                   |
| `x_i`         | node position, `a + i * Δx`                          |
| `f_xi`        | function value at the node                           |
| `coefficient` | Simpson coefficient: `1, 4, 2, 4, 2, …, 4, 1`        |
| `weighted`    | `coefficient * f_xi`                                 |

The approximation is `S_n = (Δx / 3) * sum(weighted)` (in code, the variable is named `h` for brevity but represents Δx). All three output panels (Plot, Steps, Table) and both summary fields read from this single reactive — there is one source of truth for the math.

### Styling

All CSS is inlined in `ui.R` inside a single `tags$style(HTML(...))` block. Theme:

- Roboto font (loaded from Google Fonts).
- Primary accent: `#4a90d9` (blue).
- Sidebar / dark elements: `#2d3644`.
- Iteration boxes: white background, blue header bar with an auto-incrementing CSS counter (`content: 'Iteration ' counter(section)`).

To restyle, edit the CSS block in `ui.R`. To change the iteration header text or color, look for `.calculations_box:before` and `.calculations_box.summary:before`.

### Quick checks before pushing changes (Windows / PowerShell)

```powershell
# Parse-check both files
Rscript -e "parse('ui.R'); parse('server.R'); cat('OK\n')"

# Sanity-check the math (Simpson is exact on cubics)
Rscript -e "f <- function(x) x^3 + 2*x; a <- 0; b <- 4; n <- 4; h <- (b-a)/n; x <- seq(a,b,length.out=n+1); k <- c(1,4,2,4,1); cat('approx =', (h/3)*sum(k*f(x)), ' (expected 80)\n')"
```

> **PowerShell quoting tip:** wrap the R code in **double quotes** and use **single quotes** inside the R code (the opposite of what you'd do on macOS/Linux). Avoid line breaks inside the `-e` string — chain statements with `;` instead.

---

## Credits

Developed by **Group 6**: Estelito Buenavista, Eduardo Cortes, Matthew Israel, Rhenz Largo, Cedric Rafanan. © 2026.
