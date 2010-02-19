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
Functional Reactive Programming (FRP) is ill-defined\footnote{Deliberate provocation to encite discussion.}. Make no mistake: I have great faith in the concepts and ideas that are used in conjunction with the ``FRP'' acronym. Coming from experience with modern imperative programming languages, I am often \emph{amazed} by the simplicty and beauty that functional programming offers in general, and that FRP seems to promise in particular. However, awe and amazement are no replacement for comprehension. The question ``What is FRP?'' still has no clear answer in my mind. Having read through \cite{ElliottHudak97:Fran}, \cite{nilsson_functional_2002}, \cite{courtney_yampa_2003}, \cite{hudak_arrows_2003}, \cite{Elliott2009-push-pull-frp}, and having read many blog posts, and after discussing FRP from various different angles, I am still confused. What is the essence, the common factor that makes two approaches FRP but a third not? Lately, following insights shared by Conal Elliott and others, I've been thinking that the essence of what we seek is summarized by the two following notions:
\begin{itemize}
\item \emph{Semantic precision} and clarity, as manifest by the denotational approach to design (which I learnt to appreciate from \cite{elliott_denotational_2009}).
\item \emph{Temporality}, or more specifically a functionally pure, referentially transparent and composable approach to temporally changing values. Time, as in real life, is continuous\footnote{In our normal life it is. I'm disregarding the possibility of amazingly short time quanta.}.
\end{itemize}
Elliott suggested an alternative name for FRP: ``Functional \emph{Temporal} Programming''. For a paradigm that is centered on the above two concepts, I suggest ``\emph{Denotational Temporal} Programming''. I'm not sure that these concepts are what people mean when they talk about FRP. If yes, then ``denotational-temporal'' can be used to clarify what FRP is about. If it \emph{isn't} what people mean, then I don't know what FRP is about. In any case, in this report FRP means an approach that concentrates on temporally changing values and denotational design.

\section{Remembering and forgetting}
A simple model for temporally changing values (behaviors) is a function $Time \rightarrow a$. Alternatively, for values that change only at specific points in time, the model can be a list of occurances, $[(Time, a)]$. Both models offer the possibility of ``querying'' the value at arbitrary times (see \cite{ElliotBlogGarbageCollecting}). However, arbitrary access in time violates the design principle of WWRD, ``What would reality do?''. Reality suggests that systems should not only be forbidden from accessing future values (breaking causality), but they should also not have access to arbitrary \emph{past} values. 
In reality, after all, memory is lossy and finite\footnote{I am deliberately ignoring any of the exotic properties of nature suggested by modern physics. The model I want to explore should be based on our normal experience with nature.}.
Just as it is impossible to know the future, there is no way to reach back in time and examine a temporal value as it was in the past. The best we can do is store values, and memory is finite. We are allowed to remember, but we must also forget. This limitation leads to the conclusion that an appropriate denotation for temporal values must not allow arbitrary access in time. 

If we can't access the past nor the future, if all we can access is the present, then how can we compute anything substantial from a temporal value? How do we compute things that depend on memory? For example, it seems impossible to integrate a numerical temporal value. After all, integration requires knowing the history of a function until the current time. Similarly, we may ask how to do memory-full computations on event streams. As an example consider a value that is being ``edited'' as time goes by. The editing is done by discrete actions, so at discrete points in time the value suddenly changes. If the computation depends on the ``previous'' result, then don't we need to access the past? How powerful does the temporal model have to be, what operations should be possible while retaining the limitation on arbitrary time access? I propose the following operations as test cases for a temporal model:
\begin{enumerate}
\item Integration and differentiation
\item Minimum (or maximum)
\item Time delay
\end{enumerate}
Other operations to consider are: the more general class of linear operations, and possibly also time scaling.

Let us define what we are looking for. We want a semantic interface that will allow us to define the above test cases. Some sort of a ``generalized scanr'', maybe:
\begin{code}
  gscan :: ScanFunc -> a -> TemporalValue a -> TemoralValue a
\end{code}
The argument of type \emph{ScanFunc} is a function that is specific to the kind of transformation we want to perform on the temporal value argument (and who'se type depends on $a$). \emph{TemporalValue a} may be semantically equivalent to \emph{Time $\rightarrow$ a}, but I suggest we postpone the discussion of the denotation of \emph{TemporalValue}. Instead, let's try to figure out the \emph{interface}, the precise type and meaning of our function ``\emph{?}'' (and maybe even find a suitable name).

My initial intuition was that the solution lies in ``infinitesimal time delays'', that if we allow access to the ``most recent'' past, we'll be able to perform ``memory-full'' calculations. You can probably imagine my hands waving wildly as I wrote that last sentence. A first attempt to formalize that statement was:
\begin{equation*}
  \mbox{``Infinitesimal past'' of}\ f \mbox{ at } t = \lim_{dt \rightarrow 0}{f(t-dt)}
\end{equation*}
A somewhat obvious fault with this definition is that for continuous valued functions, the infinitesimal past is always equal to the present. In fact that is exactly a common definition for continuous functions:
\begin{equation*}
  f\ \mbox{is continuous} \Leftrightarrow \forall x : f(x) = \lim_{dx \rightarrow 0}{f(x-dx)}
\end{equation*}
As such, the above attempt is useless. On the other hand, for non-continuous functions things are different. These thoughts lead to my next attempt at defining a proper notion of operations with finite memory. 

\section{Divide and Conquer}
Temporal values don't have to change whenever time changes. Nor are they limited to the range $\mathbb{R}$ of real numbers, or even to types that are infinite at all. A temporal value may even be binary, switching between two values. To facilitate the discussion, consider the following definitions:
\begin{definition}[Continuous time]
  If a function $f$ is defined over an interval $[a,b] \subset \mathbb{R}$, it is called a function of \emph{continuous time} for that interval.\footnote{It is possible that a more general type than $\mathbb{R}$ can be used here.}
\end{definition}
\begin{definition}[Discrete time]
\label{def:discrete-time}
  If for every finite interval $[a,b]$ a function $f$ is defined at a finite number of points $t \in [a,b]$ and otherwise undefined, it is called a function of \emph{discrete time}.
\end{definition}
The two classes of functions above are mutually exclusive, but not complementary. There are functions that don't fit in any of the two definitions. For example, a function of rational time ($t \in \mathbb{Q}$). I'd like to limit the discussion to functions that belong in either the continuous-time or discrete-time classes. Alternatively we could have defined discrete-time to mean a countable domain, but I'm pretty sure that the more limited definition presented above is (a) sufficiently general, and (b) easier to work with.

The above definitions categorize functions according to their domain, time. An orthogonal categorization concerns the range - the type of the function's result. The criterion I want to focus on is whether or not the result type is \emph{countable}.

Now we can divide the world of temporal values (functions of time) $Time \rightarrow a$ into four territories:
\begin{enumerate}
\item Discrete time, countable range
\item Discrete time, uncountable range
\item Continuous time, countable range
\item Continuous time, uncountable range
\end{enumerate}
This division may help us tackle the issue of how to represent finite memory systems. Since we don't know what model appropriately satisfies the condition of no arbitrary access in time, let us try to define an \emph{interface} for working with temporal values. The model may then, hopefully, be deduced from the interface that we want it to provide. 

\subsection{Discrete time}
Any function $Time \rightarrow a$ of discrete time (Definition \ref{def:discrete-time}) is equivalent to a countable set of pairs of the type $(Time,a)$, such that for every interval $[t_0,t_1] \subset Time$ there are a finite number of pairs $(t,x): t \in [t_0, t_1],x \in a$. In this case \emph{gscan} (the ``generalized scanr'') can be simply \emph{scanr} on a time-ordered sequence of the pairs. The countability of the range does not matter.

\subsection{Continuous time, countable range}

\subsection{Continuous time, uncountable range}

\section{The Generalized Memory Accumulator}
\begin{code}
  gscan :: (r -> y -> y -> DTime -> r) -> r 
            -> Temporal y -> Temporal y
\end{code}
The meaning of \emph{Temporal y} can be either \emph{[(Time, y)]} (Events) or \emph{Time -> y} (Behaviors). 

\begin{code}
  integrate :: Temporal y -> Temporal y
  integrate = gscan psum 0 
    where psum s y1 y2 dt = s + (y2+y1)/2*dt
\end{code}
\begin{code}
  differentiate :: Temporal y -> Temporal y
  differentiate = gscan pdiff 0  
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