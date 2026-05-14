library(shiny)
library(DT)

ui <- fluidPage(
  tags$head(
    HTML(
      "<link href='https://fonts.googleapis.com/css2?family=Roboto:ital,wght@0,100;0,300;0,400;0,500;0,700;0,900;1,100;1,300;1,400;1,500;1,700;1,900&display=swap' rel='stylesheet'>"
    )
  ),
  tags$style(
    HTML(
      "
      * {
        font-family: Roboto, Arial, sans-serif;
        font-weight: 400;
      }
      .title {
        text-align: center;
        color: #2d3644;
      }
      footer {
        text-align: center;
        padding: 20px 0;
        color: #2d3644;
      }
      .btn-default {
        color: white;
        background-color: #4a90d9;
        border-color: transparent;
        margin: 0 auto;
        display: block;
      }
      pre#answer, pre#error {
        background: white;
        border: 1px solid #4a90d9;
        color: #2d3644;
        font-weight: bold;
      }
      .tab-content {
        padding-top: 20px;
        min-height: 650px;
      }
      h4 {
        font-weight: 400;
      }
      .center {
        font-weight: bold;
        text-align: center;
        margin: 30px auto 0;
        color: #4a90d9;
      }
      .description {
        padding: 10px 100px 20px;
        text-align: left;
      }
      .description table td, .description table th {
        padding: 10px 20px;
        text-align: center;
      }
      .description table th {
        font-weight: bold;
        background-color: #4a90d9;
        color: white;
      }
      .description table {
        margin: 20px auto;
        border-collapse: collapse;
      }
      .description table, .description table td, .description table th {
        border: 1px solid #4a90d9;
      }
      .datatables {
        width: 100% !important;
        overflow: overlay;
      }
      .well {
        background-color: #2d3644;
        border: 1px solid #0000003d;
        color: white;
      }
      .well .control-label, .well label {
        color: white;
      }
      .formatted_calculations {
        background-color: transparent;
        border: none;
        width: 90%;
        position: relative;
        counter-reset: section;
        margin: 0 auto;
        max-height: 650px;
        overflow: overlay;
      }
      .calculations_box {
        text-align: center;
        background-color: white;
        border: 1px solid #0000003d;
        padding: 50px 0 15px;
        border-radius: 10px;
        box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2);
        position: relative;
        overflow: overlay;
        margin-bottom: 15px;
      }
      .calculations_box:first-of-type::before {
        counter-set: section;
      }
      .calculations_box:before {
        position: absolute;
        left: 0px;
        top: 0px;
        width: 100%;
        height: 40px;
        background-color: #4a90d9;
        color: white;
        border-radius: 9px 9px 0 0;
        font-size: 18px;
        padding: 8px;
        counter-increment: section;
        content: 'Iteration ' counter(section);
      }
      .calculations_box.summary:before {
        background-color: #2d3644;
        content: 'Final Result';
      }
      .calculations_box p {
        font-family: 'Courier New', monospace;
        margin: 0 auto;
        width: fit-content;
        text-align: left;
        font-size: 16px;
        font-weight: bold;
      }
      .calculations_box h4 {
        font-family: 'Courier New', monospace;
        margin: 0 auto;
        width: fit-content;
        text-align: left;
        font-size: 16px;
        font-weight: bold;
        white-space: pre-wrap;
      }
      .nav-tabs > li.active > a,
      .nav-tabs > li.active > a:focus,
      .nav-tabs > li.active > a:hover {
        color: white;
        cursor: default;
        background-color: #4a90d9;
        border: 1px solid #ddd;
        border-bottom-color: transparent;
      }
      "
    )
  ),
  titlePanel(div("Numerical Integration: Simpson's 1/3 Rule", class = "title")),

  tabsetPanel(
    tabPanel(
      "Introduction",
      fluidRow(
        div(
          class = "description",
          h4(class = "center", "What is Simpson's Rule?"),
          h4(
            HTML(
              "<strong>Simpson's Rule</strong> approximates a definite integral by partitioning <strong>[a, b]</strong> into an <strong>even number of subintervals of equal width</strong> and fitting a <strong>quadratic</strong> over each <strong>pair</strong> of consecutive subintervals."
            )
          ),
          h4(
            HTML(
              "Over the first pair of subintervals we approximate
              <span style='white-space: nowrap;'>\u222b<sub>x<sub>0</sub></sub><sup>x<sub>2</sub></sup> f(x) dx</span> with
              <span style='white-space: nowrap;'>\u222b<sub>x<sub>0</sub></sub><sup>x<sub>2</sub></sup> p(x) dx</span>,
              where <i>p(x) = Ax<sup>2</sup> + Bx + C</i> is the quadratic passing through
              <strong>(x<sub>0</sub>, f(x<sub>0</sub>))</strong>,
              <strong>(x<sub>1</sub>, f(x<sub>1</sub>))</strong>, and
              <strong>(x<sub>2</sub>, f(x<sub>2</sub>))</strong>.
              Over the next pair of subintervals we fit another quadratic through
              <strong>(x<sub>2</sub>, f(x<sub>2</sub>))</strong>,
              <strong>(x<sub>3</sub>, f(x<sub>3</sub>))</strong>, and
              <strong>(x<sub>4</sub>, f(x<sub>4</sub>))</strong>, and so on for each successive pair of subintervals."
            )
          ),
          h4(class = "center", "Simpson's Rule"),
          h4(
            HTML(
              "Assume that <strong>f(x)</strong> is continuous over <strong>[a, b]</strong>. Let <i>n</i> be a positive even integer and"
            )
          ),
          withMathJax(
            h4(class = "center", "$$\\Delta x = \\frac{b - a}{n}.$$")
          ),
          h4(
            HTML(
              "Let <strong>[a, b]</strong> be divided into <i>n</i> subintervals, each of length \u0394x, with endpoints
              <span style='white-space: nowrap;'>P = {x<sub>0</sub>, x<sub>1</sub>, x<sub>2</sub>, &hellip;, x<sub>n</sub>}</span>. Set"
            )
          ),
          withMathJax(
            h4(
              class = "center",
              "$$S_n = \\frac{\\Delta x}{3}\\Big(f(x_0) + 4f(x_1) + 2f(x_2) + 4f(x_3) + 2f(x_4) + \\cdots + 2f(x_{n-2}) + 4f(x_{n-1}) + f(x_n)\\Big).$$"
            )
          ),
          h4("Then,"),
          withMathJax(
            h4(class = "center", "$$\\lim_{n \\to +\\infty} S_n = \\int_a^b f(x)\\,dx.$$")
          ),
          h4(class = "center", "Error Bound for Simpson's Rule"),
          h4(
            HTML(
              "Let <strong>f(x)</strong> be a continuous function over <strong>[a, b]</strong> having a fourth derivative,
              <strong>f<sup>(4)</sup>(x)</strong>, over this interval. If <i>M</i> is the maximum value of
              <strong>|f<sup>(4)</sup>(x)|</strong> over <strong>[a, b]</strong>, then the upper bound for the error in using
              <i>S<sub>n</sub></i> to estimate <span style='white-space: nowrap;'>\u222b<sub>a</sub><sup>b</sup> f(x) dx</span> is given by"
            )
          ),
          withMathJax(
            h4(
              class = "center",
              "$$\\bigl|\\,\\text{Error in } S_n\\,\\bigr| \\;\\le\\; \\frac{M\\,(b - a)^5}{180\\,n^4}.$$"
            )
          ),
          h4(class = "center", "Worked Example"),
          h4(
            HTML(
              "Use <i>S<sub>2</sub></i> to approximate <span style='white-space: nowrap;'>\u222b<sub>0</sub><sup>1</sup> x<sup>3</sup> dx</span> and estimate a bound for the error in <i>S<sub>2</sub></i>.
              <br><br>Since <strong>[0, 1]</strong> is divided into two subintervals, each subinterval has length
              <strong>\u0394x = 1/2</strong>. The endpoints are <strong>{0, 1/2, 1}</strong>. With <strong>f(x) = x<sup>3</sup></strong>:"
            )
          ),
          withMathJax(
            h4(
              class = "center",
              "$$S_2 = \\frac{1}{3}\\cdot\\frac{1}{2}\\big(f(0) + 4f(1/2) + f(1)\\big) = \\frac{1}{6}\\big(0 + 4(1/8) + 1\\big) = \\frac{1}{4}.$$"
            )
          ),
          h4(
            HTML(
              "Since <strong>f<sup>(4)</sup>(x) = 0 = M</strong>, the error bound gives"
            )
          ),
          withMathJax(
            h4(
              class = "center",
              "$$\\bigl|\\,\\text{Error in } S_2\\,\\bigr| \\;\\le\\; \\frac{0\\cdot(1)^5}{180\\cdot 2^4} = 0,$$"
            )
          ),
          h4(
            HTML(
              "so the value obtained through Simpson's Rule is <strong>exact</strong>. You can verify with R: <code>f &lt;- function(x) x^3; integrate(f, 0, 1)$value</code> returns <code>0.25</code>.
              <br><br>You can reproduce this in the <strong>Calculate</strong> tab by entering <code>x^3</code>, <strong>a = 0</strong>, <strong>b = 1</strong>, <strong>n = 2</strong>."
            )
          ),
          h4(class = "center", "Applications"),
          h4(
            HTML(
              "<strong>Engineering.</strong> Computing work, moments of inertia, and other integral quantities from tabulated data.
              <br><br><strong>Physics.</strong> Evaluating integrals arising in mechanics, electromagnetism, and quantum mechanics where antiderivatives are not available.
              <br><br><strong>Area under curves.</strong> Estimating the area enclosed by experimentally measured functions.
              <br><br><strong>Signal processing.</strong> Computing energy, RMS values, and Fourier coefficients of sampled signals."
            )
          ),
          h4(class = "center", "R Function Formatting Rules"),
          HTML(
            "<table border='1'>
              <tr>
                <th>Instead of:</th>
                <th>Do</th>
              </tr>
              <tr><td>2x</td><td>2*x</td></tr>
              <tr><td>2(-x)</td><td>2*(-x)</td></tr>
              <tr><td>sin*x</td><td>sin(x)</td></tr>
              <tr><td>sin^2(x)</td><td>sin(x)^2</td></tr>
              <tr><td>logx</td><td>log10(x)</td></tr>
              <tr><td>logn(x)</td><td>log(x)</td></tr>
              <tr><td>1*expx</td><td>1*exp(x)</td></tr>
              <tr><td>absx</td><td>abs(x)</td></tr>
            </table>"
          ),
          h4(class = "center", "Conclusion"),
          h4(
            HTML(
              "Simpson's 1/3 Rule offers a powerful balance between <strong>simplicity and accuracy</strong>. By approximating the integrand with parabolas instead of straight lines, it produces results that are <strong>exact for any polynomial of degree three or lower</strong> and converges rapidly as the number of subintervals <i>n</i> grows \u2014 with an error that shrinks proportionally to <strong>1 / n<sup>4</sup></strong>.
              <br><br>For smooth, well-behaved functions, Simpson's Rule typically achieves high precision with relatively few evaluations, making it a <strong>practical default</strong> when an antiderivative is unavailable or when integrating discrete data. Its main caveats are that <i>n</i> must be even and that accuracy can degrade for functions with sharp peaks, discontinuities, or rapid oscillations \u2014 cases where adaptive methods may be preferable.
              <br><br>Use this app to <strong>experiment</strong>: compare the approximation to R's <code>integrate()</code>, watch how the error drops as you double <i>n</i>, and build intuition for when Simpson's Rule shines."
            )
          )
        ),
        align = "center"
      )
    ),
    tabPanel(
      "Calculate",
      fluidRow(
        column(
          width = 3,
          sidebarPanel(
            width = 12,
            h4("Calculator"),
            textInput("func", "Function f(x) in R format:", value = "x^3 + 2*x"),
            numericInput("a", "Lower bound a:", value = 0),
            numericInput("b", "Upper bound b:", value = 4),
            numericInput("n", "Number of subintervals n (even):", value = 4, min = 2, step = 2)
          ),
          column(
            width = 12,
            mainPanel(
              width = 12,
              h4(
                style = "font-size: 1.2em;",
                HTML("Approximated value of the integral:")
              ),
              verbatimTextOutput("answer"),
              h4(
                style = "font-size: 1.2em;",
                HTML("True value (via R's <code>integrate()</code>) and absolute error:")
              ),
              verbatimTextOutput("error")
            )
          )
        ),
        column(
          width = 8,
          tabsetPanel(
            tabPanel(
              "Plot",
              plotOutput("plot", height = "500px"),
              h4(
                style = "font-size: 1.1em; text-align: justify;",
                HTML(
                  paste(
                    "<div style='max-width: 900px; margin-left: 50px; margin-right: 50px;'>",
                    "This plot displays the function <strong>f(x)</strong> over the interval <strong>[a, b]</strong>.",
                    "The <strong>shaded blue region</strong> represents the area under the curve being approximated by Simpson's Rule.",
                    "The <strong>dashed red parabolas</strong> are the actual quadratics that Simpson's Rule fits across each consecutive pair of subintervals \u2014 the integral of these parabolas is what produces the approximation.",
                    "Black dots on the x-axis mark the <strong>subinterval points</strong> x<sub>0</sub>, x<sub>1</sub>, &hellip;, x<sub>n</sub> where the function is evaluated.",
                    "</div>"
                  )
                )
              )
            ),
            tabPanel(
              "Steps",
              uiOutput("formatted_calculations")
            ),
            tabPanel(
              "Table",
              dataTableOutput("table"),
              h4(
                style = "font-size: 1.1em; text-align: justify;",
                HTML(
                  paste(
                    "<div style='max-width: 900px; margin-left: 20px; margin-right: 20px; margin-top: 30px;'>",
                    "This table shows each node <strong>x<sub>i</sub></strong> used by Simpson's 1/3 Rule, the function value <strong>f(x<sub>i</sub>)</strong>,",
                    "the corresponding <strong>Simpson coefficient</strong> (1 at the endpoints, 4 at odd indices, 2 at even interior indices),",
                    "and the <strong>weighted value</strong> = coefficient &times; f(x<sub>i</sub>).",
                    "The approximated integral is <code>S<sub>n</sub> = (\u0394x / 3) &times; sum(weighted values)</code>.",
                    "Increasing <strong>n</strong> (while keeping it even) generally reduces the approximation error.",
                    "</div>"
                  )
                )
              )
            )
          )
        )
      )
    )
  ),
  tags$footer(
    strong("Developed by Group 6: Estelito Buenavista, Eduardo Cortes, Matthew Israel, Rhenz Largo, Cedric Rafanan"),
    br(),
    "\u00A9 2026 All rights reserved."
  )
)

server <- function(input, output, session) {

  # Build the user's function safely. Returns NULL if the expression cannot be parsed
  # or evaluated at a test point.
  user_function <- reactive({
    expr_text <- input$func
    if (is.null(expr_text) || !nzchar(trimws(expr_text))) return(NULL)
    parsed <- tryCatch(parse(text = expr_text), error = function(e) NULL)
    if (is.null(parsed)) return(NULL)
    f <- function(x) eval(parsed, envir = list(x = x))
    test_x <- if (is.numeric(input$a) && is.finite(input$a)) input$a else 0
    ok <- tryCatch({
      v <- f(test_x)
      is.numeric(v) && length(v) == 1L && is.finite(v)
    }, error = function(e) FALSE)
    if (!ok) return(NULL)
    f
  })

  # Core reactive: validates inputs and returns a data frame with one row per node.
  df_results <- reactive({
    validate(
      need(!is.null(input$func) && nzchar(trimws(input$func)), "Function input is empty"),
      need(is.numeric(input$a) && is.finite(input$a), "Lower bound a must be a number"),
      need(is.numeric(input$b) && is.finite(input$b), "Upper bound b must be a number"),
      need(is.numeric(input$n) && is.finite(input$n), "Number of subintervals n must be a number"),
      need(input$b > input$a, "Upper bound b must be greater than lower bound a"),
      need(input$n >= 2 && input$n == as.integer(input$n),
           "n must be a positive integer (at least 2)"),
      need(as.integer(input$n) %% 2 == 0,
           "n must be an even number for Simpson's Rule")
    )

    f <- user_function()
    validate(need(!is.null(f),
                  "Invalid function expression. Please check your formula (see formatting rules in the Introduction tab)."))

    a <- input$a
    b <- input$b
    n <- as.integer(input$n)
    h <- (b - a) / n

    x_i  <- seq(a, b, length.out = n + 1L)
    f_xi <- vapply(x_i, function(xv) {
      v <- tryCatch(f(xv), error = function(e) NA_real_)
      as.numeric(v)
    }, numeric(1))

    if (n == 2L) {
      coefficient <- c(1, 4, 1)
    } else {
      coefficient <- c(1, rep(c(4, 2), times = (n / 2L) - 1L), 4, 1)
    }
    weighted <- coefficient * f_xi

    data.frame(
      i           = 0:n,
      x_i         = x_i,
      f_xi        = f_xi,
      coefficient = coefficient,
      weighted    = weighted
    )
  })

  # Approximation, true value (via base R integrate()), and absolute error.
  results_summary <- reactive({
    df <- df_results()
    a <- input$a
    b <- input$b
    n <- as.integer(input$n)
    h <- (b - a) / n
    approx <- (h / 3) * sum(df$weighted)

    f <- user_function()
    true_val <- tryCatch(
      integrate(Vectorize(f), lower = a, upper = b)$value,
      error = function(e) NA_real_
    )
    abs_err <- if (is.na(true_val)) NA_real_ else abs(true_val - approx)

    list(h = h, approx = approx, true_val = true_val, abs_err = abs_err)
  })

  # ----- Plot -----
  output$plot <- renderPlot({
    df <- df_results()
    f  <- user_function()
    a  <- input$a
    b  <- input$b
    n  <- as.integer(input$n)

    safe_eval <- function(xv) {
      vapply(xv, function(xx) {
        v <- tryCatch(f(xx), error = function(e) NA_real_)
        as.numeric(v)
      }, numeric(1))
    }

    # Zoom out: extend the visible x-range 25% beyond [a, b] on each side
    # so the surrounding behavior of f(x) and the fitted parabolas are visible.
    span <- b - a
    pad  <- 0.25 * span
    x_lo <- a - pad
    x_hi <- b + pad

    x_full <- seq(x_lo, x_hi, length.out = 600)
    y_full <- safe_eval(x_full)

    # Inner grid (over [a, b]) used for the shaded region under the curve.
    x_in <- seq(a, b, length.out = 400)
    y_in <- safe_eval(x_in)

    # y-limits include both the function and the fitted parabola peaks.
    y_min <- min(c(0, y_full, df$f_xi), na.rm = TRUE)
    y_max <- max(c(0, y_full, df$f_xi), na.rm = TRUE)
    y_pad <- 0.1 * (y_max - y_min + 1e-9)

    op <- par(mar = c(5, 4, 4, 2) + 0.1)
    on.exit(par(op), add = TRUE)

    plot(x_full, y_full, type = "n",
         xlim = c(x_lo, x_hi),
         ylim = c(y_min - y_pad, y_max + y_pad),
         main = "Simpson's Rule Approximation",
         xlab = "x", ylab = "f(x)",
         cex.main = 1.4, cex.lab = 1.2, cex.axis = 1.1)

    # Shaded area under f(x) on [a, b]
    polygon(c(a, x_in, b),
            c(0, y_in, 0),
            col = "#cfe2f3", border = NA)

    abline(h = 0, col = "#888888")
    abline(v = c(a, b), col = "#bbbbbb", lty = 2)

    # Fitted Simpson parabolas: one quadratic per pair of subintervals.
    # For each triple (x_{2k}, x_{2k+1}, x_{2k+2}) build the unique parabola
    # passing through (x_i, f(x_i)) and draw it.
    for (k in seq(1, n, by = 2)) {
      x0 <- df$x_i[k]
      x1 <- df$x_i[k + 1]
      x2 <- df$x_i[k + 2]
      y0 <- df$f_xi[k]
      y1 <- df$f_xi[k + 1]
      y2 <- df$f_xi[k + 2]
      if (any(!is.finite(c(y0, y1, y2)))) next

      A <- rbind(c(x0^2, x0, 1),
                 c(x1^2, x1, 1),
                 c(x2^2, x2, 1))
      coeffs <- tryCatch(solve(A, c(y0, y1, y2)), error = function(e) NULL)
      if (is.null(coeffs)) next

      xs <- seq(x0, x2, length.out = 80)
      ys <- coeffs[1] * xs^2 + coeffs[2] * xs + coeffs[3]
      lines(xs, ys, col = "#d9534f", lwd = 2, lty = 2)
    }

    # The actual function curve (drawn last so it sits on top)
    lines(x_full, y_full, col = "#2d3644", lwd = 2)

    points(df$x_i, df$f_xi, pch = 19, col = "#4a90d9", cex = 1.3)
    points(df$x_i, rep(0, nrow(df)), pch = 19, col = "#2d3644", cex = 1.1)

    segments(df$x_i, 0, df$x_i, df$f_xi,
             col = "#4a90d9", lty = 3)

    legend("topleft",
           legend = c("f(x)", "Simpson parabolas", "Nodes x_i", "[a, b]"),
           col    = c("#2d3644", "#d9534f", "#4a90d9", "#bbbbbb"),
           lty    = c(1, 2, NA, 2),
           pch    = c(NA, NA, 19, NA),
           lwd    = c(2, 2, NA, 1),
           bty    = "n", cex = 0.95)
  })

  # ----- Steps (iteration boxes) -----
  output$formatted_calculations <- renderUI({
    df <- df_results()
    s  <- results_summary()

    boxes <- lapply(seq_len(nrow(df)), function(k) {
      row <- df[k, ]
      txt <- paste0(
        "x_", row$i, " = ", format(row$x_i, digits = 6), "\n",
        "f(x_", row$i, ") = ", format(row$f_xi, digits = 6), "\n",
        "Simpson coefficient = ", row$coefficient, "\n",
        "Weighted term = ", row$coefficient, " * ", format(row$f_xi, digits = 6),
        " = ", format(row$weighted, digits = 6)
      )
      div(class = "calculations_box", h4(txt))
    })

    weighted_strs <- format(df$weighted, digits = 6)
    sum_expr <- paste(weighted_strs, collapse = " + ")
    summary_txt <- paste0(
      "\u0394x = (b - a) / n = (", input$b, " - ", input$a, ") / ", input$n,
      " = ", format(s$h, digits = 6), "\n\n",
      "Sum of weighted values = ", sum_expr, "\n",
      "                      = ", format(sum(df$weighted), digits = 8), "\n\n",
      "S_n = (\u0394x / 3) * sum\n",
      "    = (", format(s$h, digits = 6), " / 3) * ",
      format(sum(df$weighted), digits = 8), "\n",
      "    \u2248 ", format(s$approx, digits = 8)
    )
    boxes[[length(boxes) + 1L]] <- div(class = "calculations_box summary", h4(summary_txt))

    fluidRow(
      tags$pre(class = "formatted_calculations", boxes)
    )
  })

  # ----- Table -----
  output$table <- DT::renderDataTable({
    df <- df_results()
    out <- data.frame(
      i              = df$i,
      `x_i`          = round(df$x_i, 6),
      `f(x_i)`       = round(df$f_xi, 6),
      Coefficient    = df$coefficient,
      `Weighted Value` = round(df$weighted, 6),
      check.names    = FALSE
    )
    DT::datatable(
      out,
      options = list(pageLength = 10, searching = FALSE, lengthChange = FALSE),
      rownames = FALSE
    )
  })

  # ----- Final answer & error -----
  output$answer <- renderPrint({
    s <- results_summary()
    cat(format(s$approx, digits = 10))
  })

  output$error <- renderPrint({
    s <- results_summary()
    if (is.na(s$true_val)) {
      cat("True value: not available (integrate() failed)\n")
      cat("Absolute error: NA")
    } else {
      cat("True value:     ", format(s$true_val, digits = 10), "\n", sep = "")
      cat("Absolute error: ", format(s$abs_err,  digits = 10), sep = "")
    }
  })
}

shinyApp(ui, server)
