# ACBarrierFunction

!syntax description /Kernels/ACBarrierFunction

For the Allen Cahn equation
\begin{equation}
  \frac{\partial \eta_\alpha}{\partial t} = -L \frac{\delta F}{\delta \eta_\alpha}
\end{equation}
\begin{equation}
  F = \int_V \left[m f_0 + \frac12 \kappa f_g \right] dV
\end{equation}
\begin{equation}
  f_0 = \sum_i \left(\frac{\eta_i^4}4 - \frac{\eta_i^2}2 \right) + \gamma \sum_i \sum_{j>i}\eta_i^2 \eta_j^2,
\end{equation}
ACBarrierFunction implements the term
$L \frac{\partial m}{\partial \eta_\alpha} f_0$.

This is only necessary if $m$ is a function of $\eta_\alpha$. Otherwise it returns
a value of 0.
Typically $\gamma$ should be equal to 1.5 (see [cite:moelans_quantitative_2008]),
so only a single value of $\gamma$ is supported.

!syntax parameters /Kernels/ACBarrierFunction

!syntax inputs /Kernels/ACBarrierFunction

!syntax children /Kernels/ACInterface
