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

\title{Behavioral Amnesia: \\
  Gradual Accumulation of Memory for Temporal Values}
\author{Noam~Lewis \\
  lenoam $\rightarrow$ gmail.com}
\maketitle

\begin{abstract}
  It's impossible to tell the future. Furthermore, in our physical reality, there is no way to access arbitrary events (or phenomena) in the past. We must store information in real-time if we want to use it later. Functional Reactive Programming (FRP) aims to supply a semantically simple and precise model for programming temporally reactive systems. This report is about an attempt to form a semantic model for FRP that includes a restriction on arbitrary access in time. Implementation issues (which may be critical) are purposely ignored.
\end{abstract}

\section{Introduction}
As a programmer experienced mainly in imperative languages, I am still regularly amazed by the simplicty and elegance that functional programming offers in general, and that FRP (Functional Reactive Programming) seems to promise in particular. However, awe and amazement are no replacement for comprehension. The question ``What is FRP?'' still has no clear answer in my mind. Having read a little about FRP (\cite{ElliottHudak97:Fran}, \cite{nilsson_functional_2002}, \cite{courtney_yampa_2003}, \cite{hudak_arrows_2003}, \cite{Elliott2009-push-pull-frp}) and several blog posts, and after discussing FRP with different people from various different angles, I am still confused. What is the essence, the common factor that makes one approach - but not a second - worthy of the title FRP? Lately, following insights shared by Conal Elliott and others, I've been thinking that the essence of what we seek is summarized by the two following notions:
\begin{itemize}
\item \emph{Semantic precision} and clarity, as manifest by the denotational approach to design (see \cite{elliott_denotational_2009}).
\item \emph{Temporality}, or more specifically a functionally pure, referentially transparent and composable approach to temporally changing values. Time, as in real life, is continuous.\footnote{In our normal life it is. I'm disregarding the possibility of amazingly short time quanta.}
\end{itemize}
Elliott suggested an alternative name for FRP: ``Functional \emph{Temporal} Programming''. For a paradigm that is centered on the above two concepts, I suggest also ``\emph{Denotational Temporal} Programming''. I'm not sure that these concepts are what people mean when they talk about FRP. If yes, then ``denotational-temporal'' can be used to clarify what FRP is about. If it \emph{isn't} what people mean, then I don't know what they do mean. In any case, in this report FRP means an approach that concentrates on temporally changing values and denotational design.

\section{Remembering and forgetting}
In some incarnations of FRP, temporally changing values are divided into two classes, each with its own denotation:
\begin{itemize}
\item Values that depend on continuous time. They are called \emph{behaviors}. The denotation is a function $Time \rightarrow a$ where $a$ is the value type.
\item Values that ``occur'' at specific time points. These are known as \emph{events}. One denotation is a list of occurances, $[(Time, a)]$, with monotonically non-decreasing times.
\end{itemize}
Both denotations offer the possibility of ``querying'' the value at arbitrary times (see \cite{ElliotBlogGarbageCollecting}). For behaviors we can invoke the function with any time as an argument, and with events we can traverse the list to read the value at any time. However, arbitrary access in time violates the design principle of WWRD, ``What would reality do?''. Reality suggests that systems should not only be forbidden from accessing future values (breaking causality), but they should also not have access to arbitrary \emph{past} values. 
In reality, after all, memory is lossy and finite.\footnote{I am deliberately ignoring any of the exotic properties of nature suggested by modern physics. The model I want to explore should be based on our normal experience with nature.}
Just as it is impossible to know the future, there is no way to reach back in time and examine a temporal value as it was in the past. The best we can do is store values, and memory is finite. We are allowed to remember, but we must also forget. This limitation leads to the conclusion that an appropriate denotation for temporal values must not allow arbitrary access in time. 

If we can't access the past nor the future, if all we can access is the present, then how can we compute anything (beside point-wise computations) from a temporal value? How do we compute things that depend on memory? For example, it seems impossible to integrate a numerical temporal value. After all, integration requires knowing the history of a function until the current time. Similarly, we may ask how to do memory-full computations on event streams. As an example consider a value that is being ``edited'' as time goes by. The editing is done by discrete actions, so at discrete points in time the value suddenly changes. If the editing computation depends on the ``previous'' result, then don't we need to access the past? More generally, how powerful does the temporal model have to be, what operations should be possible while retaining the limitation on arbitrary time access? I propose the following operations as test cases for a temporal model:
\begin{itemize}
\item Integration and differentiation
\item Time delay
\item Minimum (or maximum)
\end{itemize}
Note that the combination of integration and time delay will allow us to implement (for vectorial values) the general class of linear systems (via convolution). This is just a test of the minimum ``power'' that we want from our denotational framework. Integration requires memory up to the current time. Minimum is an example of an operation that also requires such memory but can't be defined (as far as I know) using integration.\footnote{Another possible test case to consider is time scaling. Is that something we really want to allow?}

Let us define what we are looking for. We want a semantic interface that will allow us to define the above test cases. First, let us use ``\emph{Temporal a}'' as the general semantic type of temporal values (both behaviors and events). Then, what we want is sort of a ``temporal scanl'', maybe:\footnote{Reactive's (see \cite{Elliott2009-push-pull-frp}) function, \emph{scanlE}, has a similar type; so do functions from other existing FRP frameworks.}
\begin{code}
  scanlT :: ScanFunc a b -> b -> Temporal a -> Temporal b
\end{code}
Remember that we're discussing denotations, and the type in an actual implementation may differ. The argument of type \emph{ScanFunc a b} is a function that is specific to the kind of transformation we want to perform on the temporal value argument. \emph{Temporal a} may be semantically equivalent to \emph{Time $\rightarrow$ a}, but I suggest we postpone the discussion of the denotation of \emph{Temporal}. Instead, let's try to figure out the \emph{interface}, as manifest in the precise type and meaning of \emph{scanlT}. Meanwhile, for \emph{Temporal a} we'll use the functional denotation \emph{Time $\rightarrow$ a}, under the assumption that the final denotation is more limited, not more permissive.

My initial intuition was that the solution lies in ``infinitesimal time delays'', that if we allow access to the ``most recent'' past, we'll be able to perform ``memory-full'' calculations. You can probably imagine my hands waving wildly as I wrote that last sentence. A first attempt to formalize that statement was:
\begin{equation*}
  \mbox{``Infinitesimal past'' of}\ f \mbox{ at } t = \lim_{dt \rightarrow 0}{f(t-dt)}
\end{equation*}
A somewhat obvious fault with this definition is that for continuous valued functions, the infinitesimal past is always equal to the present. In fact that is exactly a common definition for continuous functions:
\begin{equation*}
  f\ \mbox{is continuous} \Leftrightarrow \forall x : f(x) = \lim_{dx \rightarrow 0}{f(x-dx)}
\end{equation*}
As such, the above attempt is useless.\footnote{For the less mathematically inclined (such as myself), continuity also has a more general topological definition, which is probably more appropriate here in the context of arbitrary types $a$ in $Time \rightarrow a$.} On the other hand, for non-continuous functions things are different. These thoughts lead to my next attempt at defining a proper notion of operations with finite memory. 

\section{Divide and Conquer}
Temporal values don't have to change whenever time changes. Nor are they limited to the range $\mathbb{R}$ of real numbers, or even to types that are infinite at all. A temporal value may even be binary, switching between two values. To facilitate the discussion, consider the following definitions:
\begin{definition}[Continuous time]
  If a function $f$ is defined over an interval $[a,b] \subset \mathbb{R}$, it is called a function of \emph{continuous time} for that interval.\footnote{It is possible that a more general type than $\mathbb{R}$ can be used here.}
\end{definition}
\begin{definition}[Discrete time]
\label{def:discrete-time}
  If for every finite interval $[a,b]$ a function $f$ is defined at a finite number of points $t \in [a,b]$ and otherwise undefined, it is called a function of \emph{discrete time}.
\end{definition}
The two classes of functions above are mutually exclusive, but not complementary. There are functions that don't fit in any of the two definitions. For example, a function of rational time ($t \in \mathbb{Q}$). I'd like to limit the discussion to functions that belong in either the continuous-time or discrete-time classes. We \emph{could} have defined discrete-time to mean a countable domain, but I'm pretty sure that the more limited definition presented above is (a) sufficiently general, and (b) easier to work with.

The above definitions categorize functions according to their domain, time. An orthogonal categorization concerns the range - the type of the function's result. The criterion I want to focus on is whether or not we can say that the temporal value is a ``step function''. Stated more precisely in terms of continuity:
\begin{definition}[Discrete value]
  \label{def:discrete-value}
  A function $Time \rightarrow a$ that is piecewise constant (a step function) is called a function of \emph{discrete value}. Piecewise constancy means that for every interval $t \in [a,b]$ the function changes its value a finite number of times.
\end{definition}
Similarly we may talk about having discrete value in an interval (piecewise constant in that interval), and of functions that are piecewise discrete and non-discrete valued (piecewise constant in some intervals but not in others).\footnote{It may be possible to find types $a$ such that \emph{every} function of type $Time \rightarrow a$ is of discrete value. The characterization of such types has something to do with topology and the notion of a totally disconnected space.}

Now we can divide the world of temporal values, $Time \rightarrow a$, into four territories:
\begin{enumerate}
\item Discrete time, discrete value
\item Discrete time, non-discrete value
\item Continuous time, discrete value
\item Continuous time, non-discrete value
\end{enumerate}
This division may help us tackle the issue of how to represent finite memory systems with no arbitrary access in time. Our first step deals with functions of discrete-time, corresponding to the union of classes 1 and 2 above.

\subsection{Discrete time}
Any function $Time \rightarrow a$ of discrete time (Definition \ref{def:discrete-time}) is equivalent to a countable set of pairs of the type $(Time,a)$, such that for every interval $[t_0,t_1] \subset Time$ there are a finite number of pairs $(t,x): t \in [t_0, t_1],x :: a$. The countability of the range does not matter. In this case \emph{scanlT} (the ``temporal scanl'') can be simply \emph{scanl} on a time-ordered sequence of the pairs. Recall the type of \emph{scanl}:
\begin{code}
  scanl :: (a -> b -> b) -> b -> [a] -> [b]
  -- so the suggestion is, using the fact that our ``Temporal a'' is discrete-timed,
  -- and therefore Temporal a = [(Time, a)]:
  newtype TP a = (Time, a)
  scanlT :: (TP a -> TP b -> TP b) -> TP b -> [TP a] -> [TP b]
  -- a semantic implementation:
  scanlT = scanl
\end{code}
Thus, our interface for transforming temporal values of discrete time does not allow arbitrary access in time: it only allows access to the ``current'' time, plus access to the operation's result from the last defined time point.

\subsection{Continuous time, discrete value}
Once we enter the domain of continuous time, we can no longer meaningfully discuss ``the last defined time point''. We have shown how our attempted definition at ``infinitesimal time delay'' becomes problematic, but the problem was based on the continuity property. We are now discussing temporal values that have discrete value (Definition \ref{def:discrete-value}), and therefore continuity is impossible. We can think of our temporal values as step functions, where the value suddenly changes at some points in time. We can then construct a list of those steps, and pair each new value with the time of the step. We then again end up with an ordered list of pairs $(Time,a)$. Therefore the definition of \emph{scanlT} used in the discrete-time case above can be used here too, except that here we work on the list of steps rather than the list of defined time points.

\subsection{Continuous time, non-discrete value}
Finally, we have to deal with temporal values of continuous time and non-discrete value. This means that in a finite time interval the temporal value may change at an infinite number of time points. How can we define \emph{scanlT} in a way that makes sense in the case of non-discrete changes in value? To make things simpler, let us assume that the value changes ``smoothly'', so that at sufficient ``magnification'' of the time axis the value doesn't change much (this issue will be made precise in Section \ref{sec:bandlimit}). So far we've managed by choosing \emph{scanlT} to take a function of type $(Time,a) \rightarrow (Time,b) \rightarrow (Time,b)$, and run that function through a list of pairs, $[(Time,a)]$. With non-discrete value, however, between every two time points there are points in-between in which the function changes its value. It may be possible to define a list of step values as before, but it will be ``infinitely dense'' and the time value of one pair will be the same as the time value of the next pair.

How can we deal with this infinitely confusing sequence?


\section{The Generalized Memory Accumulator}
To answer the question, let's take a look at the usual tool used to tackle infinitly small values: the limit. Let us consider a sequence of $(Time,a)$ pairs where the time interval between successive pairs goes, in the limit, to zero. Using the denotation \emph{Temporal a} $=Time\rightarrow a$, the value of a temporal value $u$ at time $t$ is simply $u\ t$ (or $u(t)$ in the usual mathematical notation). The sequence is then:
\begin{eqnarray*}
  \{u_n\} &=& \lim_{dt \rightarrow 0}{\ldots, (t_n,\ u\ t_n), (t_{n+1},\ u\ t_{n+1}), (t_{n+2},\ u\ t_{n+2}), \ldots} \\
  dt &\ge& \max_n{(t_{n+1}-t_{n})}
\end{eqnarray*}
and the sequence is ordered, so that
\begin{eqnarray*}
  \ldots \leq t_n \leq t_{n+1} \leq t_{n+2} \leq \ldots 
\end{eqnarray*}
Now, for non-discrete temporal values of continuous time, the \emph{scanlT} function can be defined as before except that we use the sequence in the limit rather than trying to find the ``stepping points''. The difference between this and the previous cases is that we end up evaluating the temporal value at \emph{all} time points, regardless of whether the value actually changes in their vicinity at all or not. 

\begin{code}
  integrate :: Temporal y -> Temporal y
  integrate = scanlT psum 0 
    where psum s y1 y2 dt = s + (y2+y1)/2*dt
\end{code}
\begin{code}
  differentiate :: Temporal y -> Temporal y
  differentiate = scanlT pdiff 0  
    where pdiff _ y1 y2 dt = (y2-y1)/dt
\end{code}

Proof that \emph{differentiate} is inverse of \emph{integrate}:
\begin{eqnarray*}
  &\left[\left(s + \frac{y(t+dt)+y(t)}{2} dt\right) - s\right]\frac{1}{dt} \\
  &= \frac{y(t+dt)+y(t)}{2} \xrightarrow{dt \rightarrow 0} y(t)
\end{eqnarray*}

\section{Fun(cs) with Computability and Bandlimits}
\label{sec:bandlimit}

\bibliographystyle{plainnat}
\bibliography{refs}

\end{document}