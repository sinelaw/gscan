%if False
\begin{code}
{-# LANGUAGE  #-}

module GAccum where

\end{code}
%endif

\documentclass[x11names,twoside,a4paper,english]{article}
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
\textwidth 16.59cm
\textheight 21.94cm 

\bibpunct();A{},\let\cite=\citep

\newtheorem{theorem}{Theorem}
\newtheorem{example}{Example}
\newtheorem{definition}{Definition}

\begin{document}

\title{\textbf{Behavioral Amnesia} \\
  {\large or: Accumulation of Finite Memory for Temporal Values}}
\author{Noam~Lewis [lenoam at gmail.com]}

\maketitle

\begin{abstract}
\end{abstract}

\section{Introduction}
Functional Reactive Programming (FRP) is ill-defined. Make no mistake: I have great faith in the concepts and ideas that are used in conjunction with the ``FRP'' acronym. Coming from experience with modern imperative programming languages, I am often \emph{amazed} by the simplicty and beauty that functional programming offers in general, and that FRP seems to promise in particular. However, awe and amazement are no replacement for comprehension. The question ``What is FRP?'' still has no clear answer in my mind. Having read through \cite{ElliottHudak97:Fran}, \cite{nilsson_functional_2002}, \cite{courtney_yampa_2003}, \cite{hudak_arrows_2003}, and \cite{Elliott2009-push-pull-frp}, which all discuss FRP from various different angles, I am still confused: what is the essence, the common factor that makes two approaches FRP but a third not? Lately, following insights shared by Conal Elliott and others, I think that the essence of what we seek is summarized by the two following notions:
\begin{itemize}
\item \emph{Semantic precision} and clarity, as manifest by denotational approach to design (which I learnt to appreciate from \cite{elliott_denotational_2009}).
\item \emph{Temporality}, or more specifically a functionally pure, referentially transparent and composable approach to temporally changing values. This approach should, ideally, be a proper replacement for the IO monad ``sin bin''.
\end{itemize}
Elliott suggested an alternative name for FRP: ``Functional \emph{Temporal} Programming''. For a paradigm that is centered on the above two concepts, I suggest ``\emph{Denotational Temporal} Programming''. I'm not entirely sure that these concepts are what most people concentrate on when they talk about FRP. If yes, then ``denotational-temporal'' can be used to clarify what FRP is about. If it \emph{isn't} what people mean, then I don't know what FRP is about. In any case, in this report FRP means an approach that concentrates on temporally changing values and denotational design.

\section{Remembering and forgetting}
A simple model for temporally changing values (behaviors) is a function $Time \rightarrow a$. Alternatively, for values that change only at specific points in time, the model can be a list of occurances, $[(Time, a)]$. Both models offer the possibility of ``querying'' the value at arbitrary times (see \cite{ElliotBlogGarbageCollecting}). However, arbitrary access in time violates the design principle of WWRD, ``What would reality do?''. Reality suggests that systems should not only be forbidden from accessing future values (breaking causality), but they should also not have access to arbitrary \emph{past} values. 
In reality, after all, memory is lossy and finite\footnote{I am deliberately ignoring any of the exotic properties of nature suggested by modern physics. The model I want to explore should be based on our normal experience with nature.}.
Just as it is impossible to know the future, there is no way to reach back in time and examine a temporal value as it was in the past. The best we can do is store values, and memory is finite. We are allowed to remember, but we must also forget. This limitation leads to the conclusion that an appropriate denotation for temporal values must not allow arbitrary access in time. If we can't access neither the past nor the future, if all we can access is the present, then how can we compute anything substantial from a temporal value? How do we compute things that depend on memory-full operations? For example, it seems impossible to integrate a numerical temporal value. After all, integration is an operation that ``invokes'' the given function at arbitrary time points (within the integration interval). Similarly, we may ask how to do memory-full computations on event streams. As an example consider a value that is being ``edited'' as time goes by. The editing is done by discrete actions, so at discrete points in time the value suddenly changes. If the computation depends on the ``previous'' result, then don't we need to access the past?

My initial intuition was that the solution lies in ``infinitesimal time delays''. The idea was that if we allow access to the past, but only to the ``most recent'' past, we'll be able to perform ``memory-full'' calculations. Note the number of quotations required to write that hand-waiving statement. A first attempt to formalize that statement was:
\begin{equation*}
  \mbox{Infinitesimal past of } f(t) = \lim_{dt \rightarrow 0}{f(t-dt)}
\end{equation*}
A somewhat obvious fault with this definition is that for continuous functions, the infinitesimal past is always equal to the present. As such, the definition is useless. However, for non-continuous functions, things seem even more complicated. These thoughts lead to my next attempt at defining a proper notion of operations with finite memory. 

\section{Divide and Conquer}
Temporal values are not limited to values that change with continuous time. To make things clearer, we can divide the world of temporal data into four territories:
\begin{enumerate}
\item Discrete-valued functions of discrete-time, or ``discrete-discrete''
\item Continuous-discrete
\item Discrete-continuous
\item Continuous-continuous
\end{enumerate}
This division helps us tackle the issue of how to represent finite memory systems. Since we don't know what model appropriately satisfies the condition of no arbitrary access in time, let us try to define an \emph{interface} for working with temporal values. The model may then, hopefully, be deduced from the interface that we want it to provide. We shall do this separately for each of the above classes.

\subsection{Discrete-valued, discrete-time}
Any function $A \rightarrow B$ with a discrete domain $A$ is equivalent to a countable set of pairs. Alternatively the function is $A \times B$ (or if the function is partial, $A \times C$, where $C \subset B$). 

\subsection{Continuous-valued, discrete-time}
\subsection{Discrete-valued, continuous-time}
\subsection{Continuous-valued, continuous-time}

\section{The Generalized Memory Accumulator}
\begin{code}
  gaccum :: (r -> y -> y -> DTime -> r) -> r 
            -> Temporal y -> Temporal y
\end{code}
The meaning of \emph{Temporal y} can be either \emph{[(Time, y)]} (Events) or \emph{Time -> y} (Behaviors). 

\begin{code}
  integrate :: Temporal y -> Temporal y
  integrate = gaccum psum 0 
    where psum s y1 y2 dt = s + (y2+y1)/2*dt
\end{code}
\begin{code}
  differentiate :: Temporal y -> Temporal y
  differentiate = gaccum pdiff 0  
    where pdiff _ y1 y2 dt = (y2-y1)/dt
\end{code}

Proof that \emph{differentiate} is inverse of \emph{integrate}:
\begin{eqnarray*}
  &\left[\left(s + \frac{y(t+dt)+y(t)}{2} dt\right) - s\right]\frac{1}{dt} \\
  &= \frac{y(t+dt)+y(t)}{2} \xrightarrow{dt \rightarrow 0} y(t)
\end{eqnarray*}

\section{Fun(cs) with Computability and Bandlimits}

\bibliographystyle{plainnat}
\bibliography{refs}

\end{document}