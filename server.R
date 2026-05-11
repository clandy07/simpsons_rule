library(shiny)
library(DT)

function(input, output, session) {

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
