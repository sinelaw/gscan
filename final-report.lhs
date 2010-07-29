\documentclass[onecolumn,x11names,twoside,a4paper,english,final]{IEEEtran}
\usepackage{a4}
\usepackage[english]{babel}
\usepackage[pdftex]{graphicx}
\usepackage{amssymb}
\usepackage{amsmath}
\usepackage{caption}
\usepackage{float}
\usepackage{tikz}
\usepackage{subfigure}
\usepackage[shell,pdf]{dottex}
\usepackage{pdfpages}
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
This research project explores the usage of functional reactive programming for the implementation of robotic systems. As discussed in the preliminary report (included in Appendix \ref{adx:preliminary}), robotic systems belong to a wider class of ``reactive systems'', which share the need to continually react to time-varying stimuli. Programming of such systems is often a needlessly challenging task, involving too many software implementation details that are irrelevant to the problem domain. The most natural way to design reactive systems usually involves a structural, ``data-flow''-style description of the system. Each of the elements in the flow graph takes time-varying signals as input, and also outputs time-varying signals. For example, in a video processing system, an edge detection element may take a video signal as input, or images as a function of time. The output would have a similar type. Unfortunately, the description just presented is difficult to implement and use correctly in an imperative style (i.e.``classic'' programming, such as C, Java or .NET style of programming). Some of the reasons include:
\begin{enumerate}
\item General complexity inherent in imperative programming that limits our ability to effectively reason about the code (any part of the program may modify some external state, or cause side-effects).
\item The limited nature of the imperative style, which uses a ``sequence of commands'', operationally-centered model.\footnote{Object-oriented programming does not really offer an alternative in this regard: objects still communicate by processing data sequentially and sending and receiving messages from other objects.} In many cases we would like to describe the system in other terms, such as a composition or graph of functions. In other words we would rather deal with denotations than with operations.
\item The relatively weak way in which imperative languages (including the most modern variants) support or encourage modularity and reuse.
\end{enumerate}
One advantage of imperative programming is that the ``sequence of commands'' model that it follows is relatively close to the hardware's own operation, so that we may infer the resource requirements of a program by looking at its code. However, what good is a high-performance implementation that is incorrect?

There are several programming languages and environments which are designed for reactive systems. The preliminary report (Appendix \ref{adx:preliminary}, section 3.2) gives a detailed comparison of several such languages. The conclusion at the time was that none of the existing methods offer all the advantages the FRP does, specifically those provided by denotational design (as described in the preliminary report, Appendix \ref{adx:preliminary} sections 1.3-1.5, and the progress report, Appendix \ref{adx:progress} section 3). 

FRP is a paradigm that aims to make reactive systems programming more tractable. FRP supplies the programmer with very general elements and operations that should suffice for the construction of any reactive system. Programming of reactive systems in an FRP framework allows the programmer to concentrate on the structure of the system, rather than operational implementation details that are not related to the system's actual purpose. The relative simplicity of a system's description in FRP terms, compared to imperative-style programming, makes it a good solution to the problems described above. For a more detailed discussion see the appended preliminary and progress reports.

FRP is a subset of \emph{functional programming}, an approach that will described shortly in the following subsection.

\subsubsection{Functional programming}
Functional programming is an increasingly popular alternative to imperative-style programming, which does not suffer the three drawbacks just discussed. For a short introduction to functional programming see the preliminary report for this project (see Appendix \ref{adx:preliminary}). Some of the common features of functional programming are:
\begin{enumerate}
\item Every piece of code, (even a portion of a line) can be understood exactly without considering any environment (such as changes to a variable in previous lines). Behavior does not depend on some implicit state. Code independence means modularity, and it's a relatively smaller effort to generalized existing code (less effort spent ``refactoring'').
\item There are only immutable values. Thus, a program is described as explicit transformations on values, rather than (often implicit) internal state modifications that are hard to control and analyze.
\end{enumerate}
To summarize, the following advantages arise from using a functional style:
\begin{itemize}
\item Programs and their parts are naturally compositional, often we deal with composing declarative elements.
\item Code is easier to analyze.
\item Abstraction and generality is greatly encouraged, leading to more reusable code.
\end{itemize}

One disadvantage of functional programming languages is that their declarative nature is far removed from the operational, sequential model of the hardware. We are sometimes forced to learn the inner workings of functional compilers to gain understanding of how a program uses the hardware's resources. With the more advanced compilers (such as Haskell's GHC) the performance is often more than satisfactory and can exceed a ``classical'' implementation. However, there are still cases in which some level of understanding of the runtime behavior is required. On the other hand, imperative languages usually require an equivalent understanding in their own respective environments, so this may not be real a disadvantage.


\subsection{Goals and Contributions}

The goals of the project were:
\begin{itemize}
\item To learn about FRP and evaluate its advantages and disadvantage relative to the classical methods, with a specific focus on robotics.
\item To propose any possible improvements to the FRP model.
\item To build an actual robotic system using FRP and compare it to the equivalent implementation as possible with the classical methods.
\end{itemize}

The eventual contributions were:
\begin{enumerate}
\item Theory: I have proposed a mathematical operator, \emph{scanlT}, that can be used for the definition of any functional reactive system. The operator is defined in a way that appropriately limits the resulting systems to causality and other desirable properties. See the appended progress report, section III for motivation and introduction.
\item Implementation: I have implemented a minimal FRP framework, and have wrapped an image processing library (OpenCV) as FRP-style operations.
\item Robotics: Finally, I have used the implemented FRP framework to build a working robotic system. The code was written in Haskell (a functional programming language). The robotic system is based on the Segway RMP, and follows people around by tracking their faces. The robot was featured shortly on national television, but a more informative demonstration can be viewed online at \cite{haskell_robot_video_2010}.
\end{enumerate}



\section{Implementation challenges}

The FRP approach has been explored by researchers and programmers since the late 1990's, although it has its roots in various older languages and formulations. As of this writing there is no standard formulation of FRP nor is there a well accepted, tried and tested implementation. I have tried to use one of the most serious implementations to date (Yampa, \cite{hudak_arrows_2003}), and have actually implemented a prototype for an interactive visual graph editor using it. Yampa is an arrow-based formulation and implementation of FRP and is discussed in both the preliminary and progress report. The following problems were encountered while using Yampa:
\begin{enumerate}
\item Incomplete documentation, coupled with somewhat disorganized code (probably due to the less-active nature of the project in recent years).
\item Yampa's denotational model apparently does not satisfy the requirements of this project. The Yampa model uses an operator @pre@, which gives the ``previous value'' of a signal. In continuous time, that does not have any coherent meaning. There is no FRP library that actually implements correctly continuous time semantics, so using @pre@ does not make Yampa's implementation less worthy than any of the others. However, in this project I was also concerned with the definition of a precise and complete model for FRP, and wanted to avoid operations that are not well defined (such as @pre@).
\end{enumerate}
Yampa is the most widely used, best documented, and most mature FRP implementation. However, due to the reasons above (and especially due to the denotational model) I have decided to implement myself a minimal functioning FRP library for use in the robotic system.

In implementing my own FRP library I have encountered the following challenges:
\begin{enumerate}
\item The need to choose or define my own alternative model for FRP, to be used as the basis of the implementation.
\item The lack of sufficiently advanced computer vision libraries for Haskell, which prompted me to wrap portions of the OpenCV for use inside Haskell.
\item Wrapping OpenCV involved the technical obstacle of using external functions that use pre-allocated storage within Haskell without resorting to compiler-level ``hacks'' (such as assumptions about how @unsafePerformIO@ operates in certain situations). This was solved in the Processor module that I wrote, by building combinators for pre-allocated pure operations.
\item Controlling the Segway RMP from Haskell, invloving the extraction of the minimal required C code to control the robot from various examples, and wrapping the result for Haskell usage in a functional, pure API. Here too I used the Processor module.
\item Finally, battling Linux's incomplete driver support for the webcam hardware that I was using for the robotic system. The support for the webcams turned out to be inconsistent across versions. ``Pinning'' the driver version to the one version that \emph{did} work was eventually the solution.
\end{enumerate}

\section{Changes to the project plan}
One goal of the project was to evaluate the implementation using FRP by comparing it to an equivalent implementation in one of the more popular environments for reactive programming. In the original project plan, the intention was to actually implement the same robotic system twice: once using FRP, and another using an alternative, more classic language or environment. However, the implementation using FRP in Haskell ended up requiring considerable extra effort due to the lack of pre-made hardware and vision libraries. I consider these two elements - hardware and computer vision support - less relevant to the comparison and evaluation of FRP relative to other methods, the reason being that they only need to be solved once for all systems on the given platform. The bottom line is that to finish the main part of the project, namely an FRP implementation, I had to spend more time on less relevant problems. Furthermore, with prior experience implementing reactive systems using more classical methods, it's not hard to give a reasonable estimate on what such an implementation would involve. Thus, to keep the work at a reasonable amount without harming the project's goal, I decided against implementing the system also in an alternative environment. Only one implementation was carried out, and it was done using FRP principles.

On the other hand, as a side effect of this project, several new Haskell packages are now publically available. Future Haskell/FRP developers need not spend time on the lower level problems that I was required to solve before implementing the system. The new packages are detailed in the progress report (Appendix \ref{adx:progress}).

\section{Discussion of the final implementation}
As detailed in the progress report (Appendix \ref{adx:progress}, section IV), the final implementation of the robotic system is based on my own FRP framework. The framework provides functional wrapping for computer vision and robotic control elements. A few examples are given here, followed by a top-level description of the implementation:
\begin{itemize}
\item The face detection element is provided by the @cv-combinators@ package as an element with type @IOProcessor PImage [CvRect]@. By definition of the @Processor@ interface, this type is equivalent to a function from images to sequences of rectangles (rectangles are a pair of two-dimensional vectors giving the location and size of the detected area). In other words, a function that maps each image to a sequence of detected areas. A sequence is required because several faces may be detected in a single image.
\item A video camera is given as an @IOSource () PImage@ which is equivalent to a function from time to images. @IOSource@ is always a function of time, since its output depends on real-world side effects during program runtime.
\item The RMP controller elements is an @IOSink (a,a) ()@ where @a@ is some integer type. In other words, it is a function of time and a pair of integers, whose output is robotic movements (real-world side effects). The time parameter is implicit here as it is for the video camera, and arises from the dependence on (or effective output of) real-world side effects, such as images sensed by a video camera or actual robotic movements.
\item Additional elements used during the implementation include:
  \begin{itemize}
  \item An FIR filter, that was eventually dropped because it caused unacceptable latency in the robot's response, and
  \item @revertAfterT@ - an element that resets a value if a certain condition does not hold for some pre-set amount of time. This is a function from some time-dependent signal that outputs a ``reverting signal''. In our case, the reversion is to a ``no detection'' value if no face was detected for 5 seconds. During the 5 seconds after the last detection, the last detected face is assumed to have stayed stationary, allowing the robot to react more smoothely and ignore the sudden short periods with lack of detection that the face detector outputs.
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