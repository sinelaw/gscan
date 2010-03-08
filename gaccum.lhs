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
\textwidth 16.5cm
\textheight 23.5cm 

\bibpunct();A{},\let\cite=\citep

\newtheorem{theorem}{Theorem}
\newtheorem{example}{Example}
\newtheorem{definition}{Definition}

\begin{document}

\title{Behavioral Amnesia: \\
  Gradual Accumulation of Memory for Temporal Values \\
  \emph{3rd DRAFT}}
\author{Noam~Lewis \\
  lenoam $\rightarrow$ gmail.com}
\maketitle

\begin{abstract}
  It's impossible to tell the future. Furthermore, in our physical reality, there is no way to access arbitrary events (or phenomena) in the past. We must store information in real-time if we want to use it later. Functional Reactive Programming (FRP) aims to supply a semantically simple and precise model for programming temporally reactive systems. This short report is about an attempt to form a semantic model for FRP that includes a restriction on arbitrary access in time. We explore the idea of realistic accumulation of memory by considering different classes of time dependent values. Implementation issues (which may turn out to be critical) are purposely ignored.
\end{abstract}

\section{Introduction}
As a programmer experienced mainly in imperative languages, I am still regularly amazed by the simplicity and elegance that functional programming offers in general, and that FRP (Functional Reactive Programming) seems to promise in particular. However, awe and amazement are no replacement for comprehension. The question ``What is FRP?'' still has no clear answer in my mind. Having read a little about FRP (\cite{ElliottHudak97:Fran}, \cite{nilsson_functional_2002}, \cite{courtney_yampa_2003}, \cite{hudak_arrows_2003}, \cite{Elliott2009-push-pull-frp}) and several blog posts, and after discussing FRP with different people from various different angles, I am still confused. FRP seems to mean several different things, and I like when definitions are precise. So how should we define FRP? Lately, following insights shared by Conal Elliott and others, I've realized that the essence of FRP should be summarized by at least the two following notions:
\begin{itemize}
\item \emph{Semantic precision} and clarity, as manifest by the denotational approach to design (see \cite{elliott_denotational_2009}).
\item \emph{Temporality}, or more specifically a functionally pure, referentially transparent and composable approach to temporally changing values. Time, as in real life, is continuous.\footnote{In our normal life it is. I'm disregarding the possibility of amazingly short time quanta that quantum physics introduces.} For a starting point about the reasons for working with continuous time, see \cite{elliott_program_time_2010}.
\end{itemize}
Elliott suggested an alternative name for FRP: ``Functional \emph{Temporal} Programming''.\footnote{With an unfortunate acronym - FTP.} For a paradigm that is centered on the above two concepts, I suggest also ``\emph{Denotational Temporal} Programming''. I'm not sure that these concepts are what people mean when they talk about FRP. If yes, then ``denotational-temporal'' can be used to clarify what FRP is about. If it \emph{isn't} what people mean, then I don't know what they do mean. In any case, in this report FRP means an approach that concentrates on temporally changing values and denotational design. With this point cleared up we may proceed to the issue at hand.

\section{Remembering and forgetting}
In some incarnations of FRP, temporally changing values are divided into two classes, each with its own denotation:
\begin{itemize}
\item Values that depend on continuous time. They are called \emph{behaviors}. The denotation is a function $Time \rightarrow a$ where $a$ is the value type. $Time$, for our purposes, can be just $\mathbb{R}$.
\item Values that ``occur'' at specific time points. These are known as \emph{events}. One denotation is a list of occurrences, $[(Time, a)]$, with monotonically non-decreasing times.
\end{itemize}
Both denotations offer the possibility of ``querying'' the value at arbitrary times (see \cite{ElliotBlogGarbageCollecting}). For behaviors we can invoke the function with any time as an argument, and with events we can traverse the list to read the value at any time. However, arbitrary access in time is not realistic, it violates the design principle of ``What would reality do?'' (WWRD). Reality suggests that systems should not only be forbidden from accessing future values (breaking causality), but they should also not have access to arbitrary \emph{past} values. 
In reality, after all, memory is lossy and finite.\footnote{I am deliberately ignoring any of the exotic properties of nature suggested by modern physics. The model I want to explore should be based on our normal experience with nature.}
Just as it is impossible to know the future, there is no way to reach back in time and examine a temporal value as it was in the past. The best we can do is store values, and memory is finite. We are allowed to remember, but we must also forget. This limitation leads to the conclusion that an appropriate denotation for temporal values must not allow arbitrary access in time. 

If we can't access the past nor the future, if all we can access is the present, then how can we compute anything (beside point-wise computations) from a temporal value? How do we compute things that require memory? For example, it seems impossible to integrate a numerical temporal value. After all, integration requires knowing the history of a function until the current time. Similarly, we may ask how to do memory-full computations on event streams. As an example consider a value that is being ``edited'' as time goes by. The editing is done by discrete actions, so at discrete points in time the value suddenly changes. If the editing computation depends on the previous result, then don't we need to access the past? More generally, how powerful does the temporal model have to be, what operations should be possible while retaining the limitation on arbitrary time access? I propose the following operations as test cases for a temporal model:
\begin{itemize}
\item Integration and differentiation
\item Time delay
\item Maximum (or minimum)
\end{itemize}
Note that integration will allow us to implement (for vectorial values) the general class of linear time-invariant causal systems (via convolution with a known impulse response). This is just a test of the minimum ``power'' that we want from our denotational framework. Integration requires memory up to the current time. Lastly, maximum is an example of an operation that also requires such memory but can't be defined (as far as I know) using integration.\footnote{Another possible test case to consider is time scaling. Is that something we really want to allow? Time ``squeezing'' is not causal, and ``stretching'' seems to require infinite memory.}

We may ask the same question about reality. How does reality perform memory-full operations? Integration, in reality, can be achieved by a capacitor (integrates current, stores result in charge). A capacitor doesn't need to access arbitrary past currents to determine the present charge. A capacitor integrates by adding up a small amount of charge at real-time, as the current flows through it. This explanation is perhaps crude, but it captures the essence of memory in reality: saving a little information about the present, and combining that information with previously saved information.

With this idea in mind, we may try to define a semantic interface. The interface must be powerful enough to allow the above test cases. First, let us use ``\emph{Temporal a}'' as the general semantic type of temporal values (both behaviors and events). Then, what we want is a sort of a ``temporal scanl'', maybe:\footnote{Reactive's (see \cite{Elliott2009-push-pull-frp}) function, \emph{scanlE}, has a similar type; so do functions from other existing FRP frameworks.}
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
Temporal values don't \emph{have} to change whenever time changes. Nor are they limited to the range $\mathbb{R}$ of real numbers, or even to types that are infinite at all. A temporal value may even be binary, switching between two values. To facilitate the discussion, consider the following definitions:
\begin{definition}[Continuous time]
  If a function $f$ is defined over an interval $[a,b] \subset \mathbb{R}$, it is called a function of \emph{continuous time} for that interval.\footnote{It is possible that a more general type than $\mathbb{R}$ can be used here.}
\end{definition}
\begin{definition}[Discrete time]
\label{def:discrete-time}
  If for every finite interval $[a,b]$ a function $f$ is defined at a finite number of points $t \in [a,b]$ and otherwise undefined, it is called a function of \emph{discrete time}.
\end{definition}
The two classes of functions above are mutually exclusive, but not complementary. There are functions that don't fit in any of the two definitions. For example, a function of rational time ($t \in \mathbb{Q}$). I'd like to limit the discussion to functions that belong in either the continuous-time or discrete-time classes. We \emph{could} have defined discrete-time to mean a countable domain, but I'm pretty sure that the more limited definition presented above is (a) sufficiently general, and (b) easier to work with.

The above definitions categorize functions according to their domain, time. An orthogonal categorization concerns the range - the type of the function's result. The criterion I want to focus on is whether or not we can say that the temporal value is a ``step function''. Stated more precisely:
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
Any function $Time \rightarrow a$ of discrete time (Definition \ref{def:discrete-time}) is equivalent to a countable set of pairs of the type $(Time,a)$, such that for every interval $[t_0,t_1] \subset Time$ there are a finite number of pairs $(t,x): t \in [t_0, t_1],x :: a$. The discreteness of the range does not alter this representation, and therefore does not matter for our discussion. It is due to this independence on the value's type that we unify the 1st and 2nd of the four classes above. In this case \emph{scanlT} (the ``temporal scanl'') can be simply \emph{scanl} on a time-ordered sequence of the pairs. Recall the type of \emph{scanl}:
\begin{code}
  scanl :: (a -> b -> b) -> b -> [a] -> [b]
  -- so the suggestion is, using the fact that our ``Temporal a'' is discrete-timed,
  -- and therefore Temporal a = [(Time, a)]:
  newtype TP a = (Time, a)
  scanlT :: (TP a -> TP b -> TP b) -> TP b -> [TP a] -> [TP b]
  -- a semantic implementation:
  scanlT = scanl
\end{code}
\emph{scanlT} is a primitive of our semantic framework. It is used by passing a function, an initial result and a time-discrete temporal value. The function that we pass never has access to more than one time point at once. Thus, our interface for transforming temporal values of discrete time does not allow arbitrary access in time: it only allows access to the ``current'' time, plus access to the operation's result from the last defined time point, which serves as the memory. There is no access to the temporal value at any time but the present.

\subsection{Continuous time, discrete value}
Once we enter the domain of continuous time, we can no longer meaningfully discuss ``the last defined time point''. We have shown how our attempted definition of infinitesimal time delay becomes problematic, but the problem was based on the continuity property. We are now discussing temporal values that have discrete value (Definition \ref{def:discrete-value}), and therefore continuity is impossible. Our temporal values are step functions, where the value suddenly changes at some points in time. We can then construct a list of those steps, and pair each new value with the time of the step. In this fashion we again end up with an ordered list of pairs $(Time,a)$. Therefore the definition of \emph{scanlT} used in the discrete-time case above can be used here too, except that here we work on the list of steps rather than the list of defined time points.

\subsection{Continuous time, non-discrete value}
Finally, we have to deal with temporal values of continuous time and non-discrete value. This means that in a finite time interval the temporal value may change at an infinite number of time points. How can we define \emph{scanlT} in a way that makes sense in the case of non-discrete changes in value? So far we've managed by choosing \emph{scanlT} to take a function of type $(Time,a) \rightarrow (Time,b) \rightarrow (Time,b)$, and run that function through a list of pairs, $[(Time,a)]$. With non-discrete value, however, between every two time points there is another in which the function may change its value. It may be possible to define a list of step values as before, but it will be ``infinitely dense'' and the time value of one pair will be the same as the time value of the next pair.

How can we deal with this infinitely confusing sequence?


\section{The Generalized Memory Accumulator}
To answer the question, let's take a look at the usual tool used to tackle infinitely small values: the limit. Consider a sequence of $(Time,a)$ pairs where the time interval between successive pairs goes, in the limit, to zero. Using the denotation \emph{Temporal a} $=Time\rightarrow a$, the value of a temporal value $u$ at time $t$ is simply $u\ t$ (or $u(t)$ in the usual mathematical notation). The sequence is then:
\begin{eqnarray*}
  \{u_n\}_{\Delta t} &=& \{\ldots, (t_n,\ u\ t_n), (t_{n+1},\ u\ t_{n+1}), (t_{n+2},\ u\ t_{n+2}), \ldots\} \\
  & \mbox{where} & \ldots \leq t_n \leq t_{n+1} \leq t_{n+2} \leq \ldots  \\
  & \mbox{and}   & \Delta t \ge \max_n{(t_{n+1}-t_{n})}
\end{eqnarray*}
For convenience, we shall denote the sequence $\{u_n\}_{\Delta t}$ as a function of $\Delta t$ and a temporal value:
\begin{code}
  sampleList :: dt -> Temporal a -> [(Time, a)]
\end{code}

Now, for non-discrete temporal values of continuous time, the \emph{scanlT} function can be defined as before except that we use the limit $\Delta t \rightarrow 0$ on the result of applying \emph{scanlT} to the sequence (rather than trying to find the ``stepping points''). The difference between this and the previous cases is that we end up evaluating the temporal value at \emph{all} time points, regardless of whether the value actually changes in their vicinity at all or not. Since this case demands special treatment, we'll use the name \emph{scanlT'} for the continuous-time, non-discrete value scanning function:
\begin{equation*}
  \mbox{\emph{scanlT' f r ta}} = \lim_{\Delta t \rightarrow 0}{\mbox{\emph{scanlT f r (sampleList $\Delta t$ ta)}}}
\end{equation*}
Where \emph{scanlT} is as defined before, basically a specialization of \emph{scanl} for lists of pairs $(Time, a)$. The limit we have just defined must exist and converge for the meaning of \emph{scanlT'} to make any sense. The existence and convergence of the limit depends on the given function \emph{f}, but also on the nature of the temporal value \emph{ta}. To make things simpler, let us assume that the value changes ``smoothly'', so that at sufficient ``magnification'' of the time axis the value doesn't change much (this issue will be made a little more precise in Section \ref{sec:bandlimit}). This assumption ensures that as $\Delta t$ approaches zero, the sequence \emph{sampleList $\Delta t$ ta} becomes ``close'' to the continuous function (for example with a squared-mean error measure).

Now we have a candidate for an operator that ``scans over'' continuous time, but we still can't be sure about the type of functions it can scan (the type of the first argument to \emph{scanlT}). Let us check our test cases, starting with differentiation. Differentiation should be easiest to implement, because it's local - it does not require memory of the past (except the immediate past). To begin, recall one common definition of the derivative:
\begin{equation*}
  \frac{df}{dt}(t) = \lim_{\Delta t \rightarrow 0}{\frac{ f(t) - f(t-\Delta t) }{\Delta t}}
\end{equation*}
Notice that the function inside the limit expression requires knowledge of the time delta. The limit expression also makes use of \emph{two} values of the function $f$: one at the current time, $t$, and a second at $t - \Delta t$. The usage of these values by the differentiation operator suggests that we too should allow access to them in our scanning function. The values are $\Delta t$, $f(t)$ and $f(t - \Delta t)$. Otherwise we will have no way to implement differentiation and similar operations. 

An issue we have ignored when previously defining \emph{scanlT} is that by allowing \emph{f} to return the type \emph{TP b} we essentially allow writing to arbitrary times in the output temporal value.\footnote{Consider also a case where the function tries to ``rewrite history'' or the future by outputting two different values for the same time.} Allowing arbitrary access in time goes directly against our goals, so let's change also this aspect of \emph{f}'s type. Instead of taking and returning \emph{TP b} we'll change it to \emph{b}. That way, the scanning operation can use the input to calculate the output, but it can't control the time of each output: the time will be ``real time'' (i.e. the same time of the current instantaneous input).

Consequently, a better type for \emph{scanlT} is (we only change the type of the first argument):
\begin{code}
  scanlT :: (TP a -> TP a -> b -> b) -> TP b -> [TP a] -> [TP b]
\end{code}
Where as before, \emph{TP a = (Time, a)}. The function $f$ given to \emph{scanlT} takes the following arguments:
\begin{enumerate}
\item $(t,x_t)$,
\item $(t-\Delta t,x_{t-\Delta t})$, and
\item the result of applying $f$ to the previous two values.
\end{enumerate}
The function returns the result value that matches the time $t$, the value that the output of \emph{scanlT} will have at $t$. With the new type it's still not hard to ``implement'' \emph{scanlT}:
\begin{code}
  uncurry2 :: (a -> b -> c -> d)  -> ((a,b) -> c -> d)
  -- 
  scanlT :: (TP a -> TP a -> b -> b) -> TP b -> [TP a] -> [TP b]
  scanlT f b xs = scanl f' b xs'
    where 
      f' (t2,y2) = ((,) t2 . uncurry2 f) (t2, y2)
      xs' = zip (tail xs) xs
\end{code}
\emph{scanlT'} should also have its type updated. The type is identical to \emph{scanlT}: the only difference between \emph{scanlT'} and \emph{scanlT} is that the former is a limit on the latter, when applied to the \emph{sampleList} of the temporal value.

As a side note, I'd like to mention that passing explicit time values (e.g. in the pair $(t,x_t)$) is also not realistic. There is no way to measure absolute time in reality. The concept of absolute time is itself questionable. Instead, we should perhaps pass only $\Delta t$ and a pair of values, in place of two time-value pairs. Nevertheless, for now we'll leave the definition as it is.

Now, for differentiation we can write:
\begin{code}
  differentiate :: Fractional a => Temporal a -> Temporal a
  differentiate = scanlT' pdiff 0  
    where pdiff (t2,y2) (t1,y1) _ = (y2-y1)/(t2-t1)
\end{code}
and for integration:
\begin{code}
  integrate :: Fractional a => Temporal a -> Temporal a
  integrate = scanlT' psum 0 
    where psum (t2,y2) (t1,y1) s = s + (y2+y1)/2*(t2-t1)
\end{code}

Proof that \emph{differentiate} is inverse of \emph{integrate}, by substituting \emph{pdiff}'s output into \emph{psum}'s input:
\begin{eqnarray*}
  \left[\left(s + \frac{y(t+\Delta t)+y(t)}{2} \Delta t\right) - s\right]\frac{1}{\Delta t} = \frac{y(t+\Delta t)+y(t)}{2}\ \xrightarrow{\Delta t \rightarrow 0} y(t)
\end{eqnarray*}

Another test case - maximum:
\begin{code}
  maximum :: Ord a => Temporal a -> Temporal a
  maximum = scanlT' pmax MinBound
    where pmax (t2,y2) _ m = max m y2
\end{code}


\section{Food for thought}

\subsection{Time delay}

Time delay is problematic. We could allow the function passed into \emph{scanlT} to output the time value of each output it produces (output a time-value pair instead of just a value), but that opens the door to setting values at arbitrary times - exactly the problem we avoided by disallowing outputting the time. Also, time delay seems to require infinite memory for the continuous-time case. Despite these problems, time delay seems to be a valid operation - after all, it is both linear and time-invariant. Time delay can be performed via convolution with an impulse (dirac delta) placed at a non-zero time, and we have already shown that convolution is possible (because intergration is possible). However, the impulse is not really a function and thus the convolution integral in this case is no more (or less) than mathematical trickery. The best we can do is model the impulse as a limit on a constant energy signal, one which in the limit is concentrated at one time point. We end up using two limits - the integration limit and another for the convolving impulse function - something our model does not support.

Thus, because of its requirement for infinite memory and for the ability to write to arbitrary times, and despite being a linear, time-invariant operation, time delay is not neccesarily something we want to allow within our model. One consequence of this conclusion is that not all operations that are both linear and time-invariant are allowed in our model, despite belonging to a very limited class of operations.

Yet, in some intuitive sense, time delay seems like a realistic operation, one that we experience. We must once again turn to reality for ideas. How does time delay work in the real world? Apparently delays are due to reality having not only time, but also \emph{space}. In reality, we may delay information by transmitting it to a different location, an operation that must take time.\footnote{Due to the relativistic limitation of finite velocity, but also on the simpler level of us never experiencing delay-less transmission on a day-to-day basis.} FRP in general, and our proposed model in particular has no equivalent concept. This difference between our model and reality hints that we may be missing something. At the time of writing, this was an open question.

\subsection{Band-limited signals}
\label{sec:bandlimit}
We made an effort to deal with the continuous-time, non-discrete-value case. A point to consider is whether for some temporal values, sampling is sufficient. Recall Nyquist's theorem, which states that every signal (a function of time, specifically $\mathbb{R} \rightarrow \mathbb{R}$) whose Fourier transform is zero outside some finite interval, can be sampled and later reconstructed exactly. The condition is that the sampling rate be greater than twice the highest frequency in the signal. Signals satisfying the aforementioned condition are said to be \emph{band-limited}, and all the signals (temporal values) we normally deal with are band-limited. Therefore, apparently we can simply sample our continuous-time temporal values at some sufficiently high sampling frequency, and the samples will contain (and indeed do contain) all the necessary information about the signal, in a discrete-time equivalent form. However, ideal reconstruction\footnote{Shannon interpolation, if sampling is uniformly spaced} from samples to continuous-time signals is \emph{not} causal! This means that we can't meaningfully say that Nyquist sampling represents exactly the original signal, if future samples are not all known.

\subsection{Computability and continuous functions}
As explained in \cite{bauer_sometimes_2007}, computable functions are all continuous. Continuous functions can be approximated to arbitrary precision, as the precision of the function's argument approaches infinite precision. On the other hand, non-continuous functions do not have this property. Consider a step function such as $sign(x)$, which is $-1$ for $x<0$ and $1$ at $x \ge 0$. To know the value of the function in the neighborhood of $0$ even at the ``rough'' precision of just knowing whether the result is closer to $-1$ or to $1$, we need to know the argument at infinite precision. For example, if the argument's digits are $-0.000000\ldots$, we need to know ``till the end'' whether the number is really just \emph{zero}, or whether there's a $1$ somewhere that makes it a negative number. Thus, to know anything at all about the function's value around zero we may need infinite information about the exact location. How, if at all, should this fact alter our model? Do we need to assume that all temporal values are continuous (eliminating the class of ``step functions'' of continuous-time completely)?

\section{Conclusion}
We have discussed the following points:
\begin{itemize}
\item What should (or does) FRP mean? The point is apparently denotational design of a framework for temporal systems.
\item The idea that FRP should follow the realistic limit on arbitrary access in time.
\item An attempt to define an operation that makes it possible to compute various temporal functions with memory, without using access to values at arbitrary time points.
\end{itemize}
Finally we have mentioned a few open questions (for me at least) relating to the main discussion. It is my hope that this short report will inspire more rigorous, deeper insights into FRP by the readers.

\bibliographystyle{plainnat}
\bibliography{refs}

\end{document}