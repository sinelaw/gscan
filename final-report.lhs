\documentclass[onecolumn,x11names,twoside,a4paper,english,final]{IEEEtran}
\usepackage{a4}
\usepackage[english]{babel}
\usepackage[pdftex]{graphicx}
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{float}
\usepackage{tikz}
\usepackage{subfigure}
\usepackage[shell,pdf]{dottex}
\usepackage{pdfpages}
\usepackage{url}
%include polycode.fmt 

\usepackage[]{cite}

\topmargin -1.5cm        % read Lamport p.163
\oddsidemargin -0.04cm   % read Lamport p.163
\evensidemargin -0.04cm  % same as oddsidemargin but for left-hand pages
\textwidth 16.5cm
\textheight 23.5cm 

%\bibpunct();A{},\let\cite=\citep

\newtheorem{theorem}{Theorem}
\newtheorem{example}{Example}
\newtheorem{definition}{Definition}

\raggedbottom
\begin{document}

\floatstyle{boxed}  \restylefloat{code}

\includepdf{./final-report-header.pdf}

\title{FRP for Robotic Applications \\ Final Report \\ p-2010-040}
\author{Noam~Lewis \\
  lenoam $\rightarrow$ gmail.com}
\maketitle

\pagenumbering{roman} 
\tableofcontents 
\listoffigures

\newpage \pagenumbering{arabic}


\section{Introduction}

\subsection{Motivation}
This research project explores the usage of functional reactive programming for the implementation of robotic systems. As discussed in the preliminary report (included in appendix \ref{adx:preliminary}), robotic systems belong to a wider class of ``reactive systems'', those systems that need to react continually to time-varying stimuli. Reactive systems can be contrasted to programs that take an input, process it, and terminate. Programming of reactive systems is often a needlessly challenging task, involving too many software implementation details that are irrelevant to the problem domain. The most natural way to design reactive systems usually involves a structural, ``data-flow''-style description of the system. Each of the elements in the flow graph takes time-varying signals as input, and also outputs time-varying signals. For example, in a video processing system, an edge detection element may take a video signal as input, or images as a function of time. The output would have a similar type. Unfortunately, the description just presented is difficult to implement precisely and correctly in an imperative style (i.e. ``classic'' programming, such as C, Java or .NET style of programming). Some of the reasons include:
\begin{enumerate}
\item The limited nature of the imperative style, which uses a ``sequence of commands'', operationally-centered model.\footnote{Object-oriented programming does not really offer an alternative in this regard: objects still communicate by processing data sequentially and sending and receiving messages from other objects.} In many cases we would like to describe the system in other terms, such as a composition or graph of functions. In other words we would rather deal with denotations than with operations.
\item Even if we are provided with a data-flow library in an imperative language, the further we drill-down into each of the elements in the flow graph, the more likely we are to encounter the ``imperative wall'' beyond which we must revert to using imperative programming.
\item General complexity inherent in imperative programming that limits our ability to effectively reason about the code (any part of the program may modify some external state, or cause side-effects).
\item The relatively weak way in which imperative languages (including the most modern variants) support or encourage modularity and reuse. For example, it's generally impossible to re-use or generalize code on a small scale.
\end{enumerate}
One \emph{advantage} of imperative programming is that the ``sequence of commands'' model that it follows is relatively close to the hardware's own operation, so that we may infer the resource requirements of a program by looking at its code. However, what good is a high-performance implementation that is incorrect?

There are several programming languages and environments which are designed for reactive systems. This project is about a particular method, known as functional reactive programming, or FRP.\footnote{A possibly superior alternative name would have been ``denotational temporal programming'', but FRP is already widely used.} In appendix \ref{adx:preliminary} (a reproduction of the preliminary report), section 3.2 a detailed comparison of several reactive languages is given. The conclusion at the time was that none of the existing methods offer the same advantages as FRP, specifically those provided by denotational design (as described in appendix \ref{adx:preliminary} (the preliminary report) sections 1.3-1.5, and appendix \ref{adx:progress} (the progress report) section III). 

FRP is a paradigm that aims to make reactive systems programming more tractable (some of the introductory papers on FRP are \cite{ElliottHudak97:Fran}, \cite{courtney_genuinely_2001}, \cite{nilsson_functional_2002}, and most recently \cite {Elliott2009-push-pull-frp}). FRP supplies the programmer with very general elements and operations that should suffice for the construction of any reactive system. Programming of reactive systems in an FRP framework allows the programmer to concentrate on the structure of the system, rather than operational implementation details that are not related to the system's actual purpose. There is no ``imperative wall'' - the system can be described functionally (and thus declaratively) wherever we wish, even in the lower-level details. The relative simplicity of a system's description in FRP terms, compared to imperative-style programming, makes it a good solution to the problems described above. For a more detailed discussion see the appended preliminary and progress reports.

FRP is a subset of \emph{functional programming}, an approach that will described shortly in the following subsection.

\subsubsection{Functional programming}
Functional programming is an increasingly popular alternative to imperative-style programming, which does not suffer the drawbacks discussed earlier. For a short introduction to functional programming see the preliminary report for this project (see appendix \ref{adx:preliminary}). Hughes' motivational paper (see \cite{hughes_functional_1989}) is slightly outdated (being over 20 years old) but still relevant and interesting. Some of the common features of functional programming are:
\begin{enumerate}
\item Every piece of code (even a portion of a line), can be understood exactly without considering any environment (such as changes to a variable in previous lines). Behavior does not depend on some implicit state. Code independence means modularity, and it's a relatively smaller effort to generalize existing code (less effort spent ``refactoring'').
\item There are only immutable values. Numbers, strings, lists, and functions are all ``only'' values. Thus, a program is described as explicit transformations on values, rather than (often implicit) internal state modifications that are hard to control and analyze. Every program is itself a value, making it much easier to work with domain specific languages (among other advantages).
\end{enumerate}
To summarize, the following advantages arise from using a functional style:
\begin{itemize}
\item Programs and their parts are naturally compositional, often we deal with composing declarative elements.
\item Code is easier to analyze.
\item Abstraction and generality is greatly encouraged, leading to more reusable code.
\end{itemize}

One disadvantage of functional programming languages is that their declarative nature is far removed from the operational, sequential model of the hardware. We are sometimes forced to learn the inner workings of functional compilers to gain understanding of how a program uses the hardware's resources. With the more advanced compilers (such as Haskell's GHC) the performance is often more than satisfactory and can exceed a ``classical'' implementation. However, there are still cases in which some level of understanding of the runtime behavior is required. On the other hand, imperative languages usually require an equivalent understanding in their own respective environments, so this may not be a serious disadvantage.


\subsection{Goals and Contributions}

The goals of the project were:
\begin{itemize}
\item To learn about FRP and evaluate its advantages and disadvantages relative to the classical methods, with a specific focus on its applicability to robotics.
\item To propose any possible improvements to the FRP model.
\item To build an actual robotic system using FRP and compare it to an equivalent implementation using classical methods.
\end{itemize}

The eventual contributions were:
\begin{enumerate}
\item Theory: I have proposed a mathematical operator, \emph{scanlT}, that can be used for the definition of any functional reactive system. The operator is defined in a way that appropriately limits the resulting systems to causality and other desirable properties. See appendix \ref{adx:progress}, section III for motivation and introduction.
\item Implementation: I have implemented a minimal FRP framework, and have wrapped an image processing library (OpenCV) as FRP-style operations.
\item Robotics: Finally, I have used the implemented FRP framework to build a working robotic system. The code was written in Haskell (a functional programming language). The robotic system is based on the Segway RMP, and follows people around by tracking their faces. The robot was featured shortly on national television, but a more informative demonstration can be viewed online at \cite{haskell_robot_video_2010}.
\end{enumerate}



\section{Implementation challenges}

The FRP approach has been explored by researchers and programmers since the late 1990's, although it has its roots in various older languages and formulations. As of this writing there is no standard formulation of FRP nor is there a well accepted, tried and tested implementation. I have tried to use one of the most serious implementations to date (Yampa, \cite{hudak_arrows_2003}), and as a test I have implemented a prototype for an interactive visual graph editor (Graphui, detailed in appendix \ref{adx:progress}, section II). Yampa is an arrow-based formulation and implementation of FRP and is discussed in appendix \ref{adx:preliminary}, section 3.3.1 (``FRP Frameworks and Variants'') and in the description of Graphui just cited. The following problems were encountered while using Yampa:
\begin{enumerate}
\item Incomplete documentation, coupled with somewhat disorganized code (probably due to the less-active nature of the project in recent years), make it hard to choose between the multitude of functions provided by the library. Many of those functions seem to overlap, and it was not clear to me which ones are the core of the library, and which are utilities that can be expressed using the core functions.
\item Yampa's denotational model apparently does not satisfy the requirements of this project. The Yampa model uses an operator @pre@, which gives the ``previous value'' of a signal. In continuous time, that definition is useless. There is no FRP library that actually correctly implements continuous time semantics, so using @pre@ does not make Yampa's implementation less worthy than any of the others. However, in this project I was also concerned with the definition of a precise and complete model for FRP, and wanted to avoid operations that are not well defined for continuous time (such as @pre@).
\item Yampa allows one to build the flow graph of the system using arrows, but forces all impure (IO) to be placed in either ends of this graph (the @sense@ and @actuate@ functions). In some circumstances this model is too limiting.\footnote{Perhaps due to my lack of understanding of the way one must work with Yampa.}
\end{enumerate}
Yampa is the most widely used, best documented, and most mature FRP implementation. However, due to the reasons above (and especially due to the apparently lacking denotational model) I have decided to implement myself a minimal functioning FRP library for use in the robotic system.

In implementing my own FRP library I have encountered the following challenges:
\begin{enumerate}
\item The need to choose or define my own alternative model for FRP, to be used as the basis of the implementation.
\item The lack of sufficiently advanced computer vision libraries for Haskell, which prompted me to wrap portions of the OpenCV library for use within Haskell.
\item Wrapping OpenCV involved the technical obstacle of using external functions that use pre-allocated storage within Haskell without resorting to compiler-level ``hacks'' (such as assumptions about how @unsafePerformIO@ operates in certain situations). This was solved in the Processor module that I wrote, by building combinators for pre-allocated pure operations.
\item Controlling the Segway RMP from Haskell, invloving the extraction of the minimal required C code to control the robot from various examples, and wrapping the result for Haskell usage in a functional, pure API. Here too I used the Processor module.
\item Finally, battling Linux's incomplete driver support for the webcam hardware that I was using for the robotic system. The support for the webcams turned out to be inconsistent across versions. ``Pinning'' the driver version to the one version that \emph{did} work was eventually the solution.
\end{enumerate}

\section{Changes to the project plan}
One goal of the project was to evaluate the implementation using FRP by comparing it to an equivalent implementation in one of the more popular environments for reactive programming. In the original project plan, the intention was to actually implement the same robotic system twice: once using FRP, and another using an alternative, more classic language or environment. However, the implementation using FRP in Haskell ended up requiring considerable extra effort due to the lack of pre-made hardware and vision libraries. I consider these two elements - hardware and computer vision support - less relevant to the comparison and evaluation of FRP relative to other methods, the reason being that they only need to be solved once for all systems on the given platform. The bottom line is that to finish the main part of the project, namely an FRP implementation, I had to spend more time on less relevant problems. Furthermore, with prior experience implementing reactive systems using more classical methods, it's not hard to give a reasonable estimate on what such an implementation would involve. Thus, to keep the amount of work reasonable without harming the project's goal, I decided against implementing the system also in an alternative environment. Only one implementation was carried out, and it was done using FRP principles.

On the other hand, as a side effect of this project, several new Haskell packages are now publically available. Future Haskell/FRP developers need not spend time on the lower level problems that I was required to solve before implementing the system. The new packages are detailed in the progress report (included here as appendix \ref{adx:progress}).

\section{Research results summary - a proposed model for FRP}
\subsection{Background}
The model I designed for FRP is based on two problems.

First, all of the models of FRP that I encountered had primitives for integration of numerical signals as a basic element. Reactive \cite{Elliott2009-push-pull-frp} also has a more general accumulator (@accumE@) for events, which are values occuring in discrete points in time. However, none of the FRP models seemed to have a generalization of integration for continuous time, nor did I find a definition in the spirit of @accumE@ that could serve for both continuous and discrete time signals. 

The second problem is that none of the FRP models studied restricted the systems \emph{by definition} to be causal. For example, with the semantics of Yampa there is nothing in the definition of signal functions that ensures that they are causal. It is possible to add a causality \emph{requirement} to any model, but that will not ensure that all systems implemented with the model's building blocks are actually causal. 

These problems and a possible solution was discussed in a report I wrote on the subject (see \cite{lewis_gaccum_2010}), that was also included in the progress report of this project. It is included here as appendix \ref{adx:progress}, section III. However in that report I did not address issues such as pathologically discontinuous functions, nor did I offer a unified framework for both discrete and continuous time signals. Later, in a pair of blog posts (see \cite{lewis_axiomatic_frp_2010} and \cite{lewis_insensitivity_2010}), I have discussed ways of mending these issues and received some feedback from active FRP researchers. The following desciribes the final definitions resulting from my research.

\subsection{The proposed model}
The following basic definitions facilitate a framework for precisely defining the basic primitive, @scanlT@.

\begin{definition}[Time domain]
  Any measurable, ordered  set $T$ can serve as a time domain for signals.
\end{definition}

\begin{definition}[Signal]
  A measurable function $T \rightarrow A$ on a time domain $T$ to any arbitrary set $A$ is a signal. Note that signals are not limited to numerical or even vectorial values.
\end{definition}

\begin{definition}[Smaller subset]
  A subset $U$ of an ordered set $T$ is said to be \emph{smaller} than another subset $V \subset T$ if:
  \begin{enumerate}
  \item $U \subset V$, and
  \item $\forall u \in U, s \in T \setminus V: u < s$
  \end{enumerate}
  Notation: $U \sqsubseteq V$.
\end{definition}

\begin{definition}[Reactive system]
  A \emph{reactive system} is a causal function from signals to signals, that is $(T_1 \rightarrow A) \rightarrow (T_2 \rightarrow B)$. Let a system map input $f$ to output $g$. Then causality means that if $U_2 \sqsubseteq V_2 \subset T_2$ and there exists $V_1 \subset T_1$ such that $g(V_2)$ depends only on $f(V_1)$, then there exists $U_1 \sqsubseteq V_1$ such that $g(U_2)$ depends only on $f(U_1)$. 
\end{definition}

Note that the time domains of the input and output signal sets of a reactive system may be different (for example, a system may map continuous-time signals to discrete-time ones). Evidently, these definitions make it possible to work with both discrete and continuous-time signals in a unified framework. Specifically, using measurable sets and functions allows us to take advantage of the same technique used in modern integration to avoid the problems that were discovered in Riemann integration, and to avoid the same sort of problems. 

\begin{definition}[Scanning function]
  Any function of the type $A \rightarrow R \rightarrow B \rightarrow B$ (or using common mathematical notation, $A \times R \times B \rightarrow B$) qualifies as a \emph{scanning function} with domain $A$ and recursive range $B$.
\end{definition}

The idea of the @scanlT@ operator is just a simple generalization of the well-known veteran function @scanl@ of functional programming languages. The original @scanl@ uses a simplified scanning function (one that doesn't take a value from $R$) to transform a sequence with elements $\in A$ to a sequence of elements $\in B$. My proposal, @scanlT@ takes sequences of values sampled from the original signals. We also add a time parameter to the scanning function so that it is possible to have the output depends on the temporal characteristic of a signal. Then, we take the limit as the measure between time steps in the sampling goes to zero. More precisely:

\begin{definition}[Sample sequence]
  Let $f:T\rightarrow A$ be a signal. Pick an ordered partitioning $U_n$, of $T$ such that $U_i \cap U_j = \emptyset$, $U_i \sqsubset U_j$, $\cup_{n \in \mathbb{Z}} U_n = T$. Then a sample sequence of $f$ is a sequence of $a_n \in f(U_n)$. The \emph{maximum sampling time} of $a_n$ is defined as $\max{\mu(U_i)}$, where $\mu$ is a measure defined on $T$.

\end{definition}

\begin{definition}[scanlT]
  The operator @scanlT@ takes the following arguments:
  \begin{enumerate}
  \item A scanning function, $s : A \rightarrow R \rightarrow B \rightarrow B$,
  \item an initial output value, $b_0 \in B$,
  \item a start time $t_0 \in T$, and
  \item an input signal $f : T \rightarrow A$.
  \end{enumerate}
  The operator outputs an output signal, $g : T \rightarrow B$. Its output is defined as follows. Let $a_n$ be a sample sequence of $f$. To calculate the output of @scanlT@ we recursively apply the scanning function, starting with the value of $a_0 = f(t_0)$, the real number $0$ and the initial output $b_0$. The scanning function will map this to an output $b_1$ in $B$. We proceed to the next sample $a_1$ in the sequence of samples of $f$ and calculate again, this time passing as the second parameter (the real) the value of the measure of $U_0 \cup U_1$, and the output of the previous application - $b_1$ - as the input from $B$. At step $k$ we take $a_k$, $\mu(U_{k-1} \cup U_k)$ and $b_k$ as inputs. The result is a sequence $b_n \subset B$, that can be associated with the ordered partitioning $U_n$ (that corresponds to the input samples $a_n \subset A$). To complete the definition, we take the limit as the \emph{maximum sampling time} of $a_n$ goes to zero. 
\end{definition}

By definition, the output can not depend on future inputs, so @scanlT@ enforces causality. Let use study two specific time domains, to illustrate the meaning (and the versatility) of the definitions given above. 

\subsubsection{Discrete real time}
Discrete, real time is defined as a set of reals. Let us denote this set $D$. The set has order (the order of the reals). We define the following measure: for every subset $U$ of $D$, $/mu(U) = \max{U} - \min{U}$ where those are the maximum and minimum elements in $U$, respectively. Taking the limit of the ``most dense sampling'' as defined in @scanlT@, leaves us with something very similar to the classic @scanl@. The second parameter to the scanning function is simply the time difference between the current sample and the previous sample in the discrete-time domain. 

\subsubsection{Continuous real time}
For continuous, real time, we use the real line as the time domain. It is ordered. We use the length (Lebesgue) measure $dt$. It is not hard to define Reimann integration using @scanlT@ and an appropriate scanning function, and also differentiation (this was done in appendix \ref{adx:progress}, section III-E). Furthermore, it is possible to define even Lebesgue integration using @scanlT@ (which actually doesn't require the limiting step, but isn't harmed by it).

Future work may focus on clarifying which classes of operations can or can't be defined using @scanlT@.

\section{Discussion of the final implementation}
As detailed in the progress report (appendix \ref{adx:progress} of this report, section IV), the final implementation of the robotic system is based on my own FRP framework. Using this framework I then implemented packages providing functional wrapping for computer vision and robotic control elements. A few examples are given here, followed by a top-level description of the implementation:
\begin{itemize}
\item The face detection element is provided by the @cv-combinators@ package as an element with type
\begin{code}Processor Image [CvRect]
\end{code}
By definition of the @Processor@ interface, this type is equivalent to a function from images to sequences of rectangles (rectangles are a pair of two-dimensional vectors giving the location and size of the detected area). In other words, a function that maps each image to a sequence of detected areas. A sequence is required because several faces may be detected in a single image.
\item A video camera is given as an @IOSource () Image@ which is equivalent to a function from time to images. @IOSource@ is always a function of time, since its output depends on real-world side effects during program runtime.
\item The RMP controller elements is an @IOSink (a,a) ()@ where @a@ is some integer type. In other words, it is a function of time and a pair of integers, whose output is side effects (in this case, robotic movements). The time parameter is implicit here as it is for the video camera, and arises from the dependence on (or effective output of) real-world side effects, such as images sensed by a video camera or actual robotic movements.
\item Additional elements used during the implementation include:
  \begin{itemize}
  \item An FIR filter, that was eventually dropped because it caused unacceptable latency in the robot's response, and
  \item @revertAfterT@ - an element that resets a value if a certain condition does not hold for some pre-set amount of time. This is a function from some time-dependent signal that outputs a ``reverting signal''. In our case, the reversion is to a ``no detection'' value if no face was detected for 5 seconds. During the 5 seconds after the last detection, the last detected face is assumed to have remained stationary, allowing the robot to react more smoothely and ignore the sudden short periods of no detection that the face detector suffers.
  \end{itemize}

\end{itemize}

\section{FRP compared to other methods}

\section{Conclusions and recommendations}


\pagebreak

\bibliographystyle{IEEEtran}
\bibliography{refs}

\pagebreak

\appendices

\section{Preliminary Report}
\label{adx:preliminary}
\includepdf[pages=-]{./preliminary-report.pdf}

\section{Progress Report}
\label{adx:progress}
\includepdf[pages=-]{./progress-report.pdf}


\end{document}