\documentclass[onecolumn,x11names,twoside,a4paper,english]{IEEEtran}
\usepackage[english]{babel}
\usepackage[pdftex]{graphicx}
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{caption}
\usepackage{float}
\usepackage{tikz}
\usepackage{euler}                                %Nicer numbers
\usepackage{subfigure}
\usepackage[shell,pdf]{dottex}
%include polycode.fmt 

\usepackage[]{natbib}

\topmargin -1.5cm        % read Lamport p.163
\oddsidemargin -0.04cm   % read Lamport p.163
\evensidemargin -0.04cm  % same as oddsidemargin but for left-hand pages
\textwidth 16.5cm
\textheight 23.5cm 

%\bibpunct();A{},\let\cite=\citep

\newtheorem{theorem}{Theorem}
\newtheorem{example}{Example}
\newtheorem{definition}{Definition}

\begin{document}

\floatstyle{boxed}  \restylefloat{code}

\begin{figure}[h!]
  \begin{center}
    \includegraphics[scale=0.7]{./progress-report-header.pdf}
  \end{center}
\end{figure}

\title{FRP for Robotic Applications \\ Final Report \\ p-2010-040}
\author{Noam~Lewis \\
  lenoam $\rightarrow$ gmail.com}
\maketitle

\tableofcontents
\listoffigures
\pagebreak

\section{Introduction}

\subsection{Motivation}
This research project explores the usage of functional reactive programming for the implementation of robotic systems. As discussed in the preliminary report (see appendix), robotic systems belong to a wider class of ``reactive systems'', which share the need to continually react to time-varying stimuli. Programming of such systems is often a needlessly challenging task, involving too many software implementation details that are irrelevant to the problem domain. The most natural way to design reactive systems usually involves a structural, ``data-flow''-style description of the system. Each of the elements in the flow graph takes time-varying signals as input, and also outputs time-varying signals. For example, in a video processing system, an edge detection element may take a video signal as input, or images as a function of time. The output would have a similar type. Unfortunately, the description just presented is difficult to implement and use correctly in an imperative style (i.e.``classic'' programming, such as C, Java or C# style of programming). Some of the reasons include:
\begin{enumerate}
\item General complexity inherent in imperative programming that limits our ability to effectively reason about the code (any part of the program may modify some external state, or cause side-effects).
\item The limited nature of the imperative style, which uses a ``sequence of commands'', operationally-centered model.\footnote{Object-oriented programming does not really offer an alternative in this regard: objects still communicate by processing data sequentially and sending and receiving messages from other objects.} In many cases we would like to describe the system in other terms, such as a composition or graph of functions. In other words we would rather deal with denotations than with operations.
\item The relatively weak way in which imperative languages (including the most modern variants) support or encourage modularity and reuse.
\end{enumerate}
One advantage of imperative programming is that the ``sequence of commands'' model that it follows is relatively close to the hardware's own operation, so that we may infer the resource requirements of a program by looking at its code. However, what good is a high-performance implementation that is incorrect?

Functional programming is an increasingly popular alternative to imperative-style programming, which does not suffer the three drawbacks just discussed. For a short introduction to functional programming see the preliminary report for this project (see appendix). To summarize the features and advantages:
\begin{enumerate}
\item Every piece of code, even a portion of a line can be independentally explained. Behavior does not depend on some implicit state. Code independence means modularity, and it's a relatively smaller effort to generalized existing code (less effort spent ``refactoring'').
\item There are only immutable values. Functional programming eliminates ``special'' types (such as functions, references or objects) and declares that all types are ``born equal'' and are all immutable values. Again this means that 
\end{enumerate}

\pagebreak

\bibliographystyle{IEEEtran}
\bibliography{refs}

\end{document}