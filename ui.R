library(shiny)
library(DT)

fluidPage(
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
              "<strong>Simpson's Rule</strong> is a numerical method for approximating the value of a definite integral. Instead of fitting straight lines (as the Trapezoidal Rule does), Simpson's Rule fits <strong>parabolas</strong> over pairs of subintervals, producing a much more accurate estimate of the area under a curve. It is widely used in <strong>engineering, physics, signal processing, and any field where closed-form integration is difficult or impossible</strong>."
            )
          ),
          h4("The composite Simpson's 1/3 Rule formula is given by:"),
          withMathJax(
            h4(
              class = "center",
              "$$S_n = \\frac{\\Delta x}{3}\\left[f(x_0) + 4f(x_1) + 2f(x_2) + 4f(x_3) + 2f(x_4) + \\cdots + 2f(x_{n-2}) + 4f(x_{n-1}) + f(x_n)\\right]$$"
            )
          ),
          h4("where:"),
          withMathJax(
            h4(class = "center", "$$\\Delta x = \\frac{b - a}{n}$$")
          ),
          h4(
            HTML(
              "and the interval <strong>[a, b]</strong> is divided into <i>n</i> subintervals. The number of subintervals <i>n</i> <strong>must be even</strong> for Simpson's 1/3 Rule to apply, since it works on pairs of subintervals."
            )
          ),
          h4("The error bound for Simpson's 1/3 Rule is:"),
          withMathJax(
            h4(
              class = "center",
              "$$\\bigl|\\,\\text{Error in } S_n\\,\\bigr| \\;\\le\\; \\frac{M\\,(b - a)^5}{180\\,n^4}$$"
            )
          ),
          h4(
            HTML(
              "where <i>M</i> is the maximum value of <strong>|f<sup>(4)</sup>(x)|</strong> over <strong>[a, b]</strong>."
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
                    "Black dots on the x-axis mark the <strong>subinterval points</strong> x<sub>0</sub>, x<sub>1</sub>, &hellip;, x<sub>n</sub>",
                    "at which the function is evaluated to fit parabolas across consecutive pairs of subintervals.",
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
