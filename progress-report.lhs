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

\title{Progress Report - p-2010-040}
\author{Noam~Lewis \\
  lenoam $\rightarrow$ gmail.com}
\maketitle

\tableofcontents
\listoffigures
\pagebreak

\section{Progress Report}
This report summarizes the progress on the project. For detailed information about the project see the appended preliminary report. 

\subsection{Progress summary}
At this point, I have:
\begin{enumerate}
\item Written a moderately complex test program using Yampa.
\item Researched one aspect of FRP, and wrote a report about it, which is included here as Section \ref{sec:behave}.
\item Implemented HOpenCV: Low-level Haskell bindings to OpenCV (not comprehensive, but enough for this project and easily extensible).
\item Implemented a general framework for chaining operations that require resources (the Processor module).
\item Used the Processor module to write a functional wrapping of HOpenCV, called ImageProcessors.
\end{enumerate}

\subsubsection{Surprises and delays}
\label{subsec:delays}
After writing the test program, I have concluded that Yampa is not a suitable framework for FRP for various reasons detailed in Section \ref{sec:graphui}. As a result, a lot more work has to be done in order to complete an FRP-ish implemenation of the robotic system.

In addition, two unplanned things have hindered the progress of this project relative to schedule:
\begin{enumerate}
\item Unexpected work load on other study duties: the courses I took in the first semester were much more demanding than I have expected, and almost no work was performed in that time until the end of the exam period. This work load resulted in a delay of more than a month on the project's schedule.
\item Binding the video hardware to Haskell in a functionally clean interface turned out to be more complex than expected. The work is mostly done on this front, and is detailed in Section \ref{sec:opencv}.
\end{enumerate}

The following sections describe the progress in more detail.

\subsection{Progress breakdown by tasks}
\label{sec:summary}
The first stage of the project plan was to implement the robotic system using FRP. This stage is still in progress - the other stages (Stage 2 ``Implementation using another reactive language'', Stage 3 ``Comparison'' and Stage 4 ``Conclusion'') have not been worked on so far.

We enumerate the status of the sub-tasks that are part of the current stage, Stage 1:
\begin{enumerate}
\item Test program - ``Implementation of a simple robotic program using Yampa FRP''. The test program I chose to work on was not robotic, to limit the scope of the work to the original intention: testing Yampa FRP. I have completed this tasks succesfully with the design and implementation of the Graphui graph visual editor prototype, as detailed in Section \ref{sec:graphui}.
\item ``Detailed design of the robot's controlling program, using FRP abstractions.'' This task turned out to be slightly inappropriately placed, and should have been scheduled after the I/O modules, due to lack of information on the available primtives. Furthermore, FRP's advantage is that design and implementation are nearly the same task, so we can safely erase this task from our to-do list.
\item ``Detailed test specification'' - this task was also misplaced, and will be carried out when the rest of this stage (tasks on this list) are completed.
\item  \textbf{In progress}: ``I/O modules - Implementation of the input/output modules for communication between the controlling program and the RMP (the robot platform), and for receiving video input from the USB video camera.'' This is the task that is currently being worked on. The video I/O part has been completed, with additional, unplanned work on binding Haskell to OpenCV to allow video processing. This task is detailed in Section \ref{sec:opencv}. No work has begun on binding Haskell to the robotic hardware via usb, but it seems much simpler, also because now the video issue has been mostly resolved and understood.
\item ``Implementation using Yampa'' - one result of the test program was that Yampa has been found inappropriate, so there is much more work in this stage. The groundwork has begun with the implementation of the Processor module as detailed in \ref{sec:opencv}.
\item ``Testing'' - to be performed when all other tasks are completed.
\end{enumerate}

\begin{figure}[h]
\label{fig:plan}
  \begin{center}
    \includegraphics[scale=0.7]{./updated-plan.pdf}
  \end{center}
  \caption{Updated time plane.}
\end{figure}

\subsection{Budget and Timetable Updates}
The budget does not require any change, as I still believe the project can be completed within the work-hour budget described in the preliminary report.


The timetable needs a 1.5-month shift due to the reasons explained Subsection \ref{subsec:delays}. The original timetable is shown on page 30 of the appended preliminary report. The updated plan is shown in Figure \ref{fig:plan}.




\section{Graphui: The Visual Graph Editor}
\label{sec:graphui}

\subsection{Semantic design of Graphui}

\subsubsection{Annotated Graph}
Graphui is an interface between the user and an *annotated graph*. Two aspects of the graph can be edited:

\begin{enumerate}
\item Structure: includes how nodes are connected and the values associated with the nodes and/or edges.
\item Visual representation: how the graph is displayed, including positions, shapes, colors and textures of nodes and edges, fonts, resolution, zoom and pan, etc.
\end{enumerate}

We call the combination of these two an *annotated graph*. The graph itself is the structure, and the annotations are the visual representation. Obiously there is a tight relation between the graph structure and its visual representation. There shouldn't be any data about elements that don't exist in the graph, and the data *must* be present for every element of the graph.

\textbf{Graph Structure}

There are many possible ways to define a graph. A very simple one is a set of pairs, where each pair specifies an edge between two nodes (also called vertices). This definition disallows unconnected nodes or more than one edge between two nodes, and does not support ordered edges, or values on edges. We want all of the above. We also want some way to "reference" nodes and edges in the graph to allow annotating extra data. A sufficient definition (but perhaps not the simplest one possible) is as follows.

A graph with $N$ nodes and $M$ edges is a function $G : \mathcal{V} \rightarrow [\mathcal{E}]$, where:

\begin{itemize}
\item $\mathcal{V}$ is the set of nodes (vertices), $\mathcal{V} = \{ (n,x) : n \in \mathbb{N}, x \in X , n < N \} \subset \mathbb{N} \times X$. 
  \begin{itemize}
  \item The number $n$ is the *id* of the node. The node with id $n$ is denoted $v_n$, and $id_n(v_n) = n$. 
  \item The value  $x$ of a node is given by $val(v_n)$.
  \end{itemize}
\item $\mathcal{E}$ is the set of edges, $\mathcal{E} = \{ (m,x,v_j,v_k) : v_j,v_k \in \mathcal{V}, m \in \mathbb{N}, x \in X , m < M \} \subset \mathbb{N} \times X \times \mathcal{V} \times \mathcal{V}$. 
  \begin{itemize}
  \item The node $v_j$ is the *source* node and $v_k$ is the *destination* node of the edge.
  \item The edge with id $m$ is denoted $e_m$ and $id_e(e_m) = m$. The value $x$ of an edge is given by $val(e_m)$. 
  \item Alternatively, we can use the number of a node to specify it, replacing $\mathcal{V} \times \mathcal{V}$ with $\mathbb{N} \times \mathbb{N} (= \mathbb{N}^2)$. Then define $\mathcal{E} = \{ (m,x,j,k) : m,j,k \in \mathbb{N}, x \in X, m < M, j,k < N \} \subset \mathbb{N}^3 \times X$.
  \item In any case, the id of the source node (not the node itself) of an edge is given by $source(e_m) = id_n(v_j) = j$, and the destination is given by $dest(e_m) = id_n(v_k) = k$.
  \end{itemize}
\item $[\mathcal{E}]$ is a list (ordered sequence) of elements from $\mathcal{E}$.
\item $X$ is the set of values (our graph can contain values on the nodes and edges) and
\item $\mathbb{N}$ denotes the natural numbers, including $0$.

\end{itemize}


In words, a graph is a function from nodes to (finite) ordered lists of edges, where both nodes and edges have a number and a value associated with them.

A node or edge is called a *graph element*, and every graph $G$ has a set of elements $G_{ne} = \mathcal{V} \cup \mathcal{E}$. The number associated with each element is the *identifier* (id) of that element. Identifiers are separately unique for nodes and for edges . The id, plus the knowledge of whether it's a node or an edge, can be used as a reference to the element from external data. With every graph $G$ there are associated element map partial functions $id_n^{-1}(n) = v_n$ and $id_e^{-1}(m) = e_m$, where $n < N$ and $m < M$.

For every graph $G$, the corresponding *global id function* $id_G$ maps nodes and edges (elements of $G_{ne}$) to a pair $(t,k)$, where $t \in \{n,e\}$ (isomorphic to booleans) specifies whether the given element was a node or an edge, and $k$ is the id of that element. The image (codomain) of $id_G$ is denoted $ID_G$. There is also $id_G^{-1} : ID_G \rightarrow G_{ne}$.

Finally, $\mathcal{ID}$ is the set of all possible id's: $\mathcal{ID} = \{(t,k) : t \in \{n,e\}, k \in \mathbb{N} \}$.

\textbf{Graph Identity and Isomorphism}

Two graphs are *identical* if they have the same structure excluding the ordering (the indexing, the parameters $n$ and $m$ of the nodes and edges) which can differ. To be more precise, two graphs $G_1, G_2$ are identical if there are permutations $P_n, P_e$ such that:

\begin{itemize}
\item For all $v_{n'}$ nodes of $G_1$, and $u_n$ nodes of $G_2$: $val( v_{P_n(n)} ) = val(u_n)$.
\item For all $c_{m'}$ edges of $G_1$, and $d_m$ edges of $G_2$:

  \begin{itemize}
  \item $val( c_{P_e(m)} ) = val(d_m)$,
  \item $source( c_{P_e(m)} ) = source(d_m)$, and
  \item $dest( c_{P_e(m)} ) = dest(d_m)$.
  \end{itemize}
\end{itemize}

Two graphs are *isomorphic* if they have the have the same structure except for values. Precisely when there are permutations such that:

For all $c_{m'}$ edges of $G_1$, and $d_m$ edges of $G_2$:

\begin{itemize}
\item $source( c_{P_e(m)} ) = source(d_m)$, and
\item $dest( c_{P_e(m)} ) = dest(d_m)$.
\end{itemize}



\textbf{Visual Representation}

A main feature of Graphui is supposed to be automatic layout. We'll use Graphviz's dot tool (http://www.graphviz.org/) for this purpose, until we design and implement our own layout algorithm (if ever). At first glance this means that there is no reason to store node and edge positions for a graph, because they can be automatically determined. This isn't true because

\begin{enumerate}
\item we may want to allow the user to move elements manually,
\item there may be different layout algorithms (such as dot vs. twopi), and
\item some future algorithm may calculate other visual parameters (such as colors).
\end{enumerate}

Last but not least, remembering the specific values calculated from the layout algorithm is useful for features other than rendering. For these reasons the visual representation includes values of parameters *after* calculating them using automatic algorithms. The definition I chose is as follows:

A visual representation of a graph $G$ with $N$ nodes and $M$ edges, is a (total) function $H : ID_G \rightarrow \mathcal{D}$, where $\mathcal{D}$ is the domain of visual representation data. For example, elements in $D$ may be $n$-tuples containing information such as shape, position, size, etc. of each element in the graph. For each parameter we may choose to include a boolean value specifying whether that parameter was calculated automatically or set manually by the user. We may also choose to specify whether parameters are present or not (``Maybe a'' style).

\textbf{Annotated Graph}

An annotated graph is a pair $(G, H)$ of a graph structure $G$ and a matching visual representation $H$. The set of annotated graphs is denoted $\mathcal{AG}$.

\subsubsection{Image}
For the visual two-dimensional images that Graphui must render, we use the semantic model of a function: $\mathbb{R}^2 \rightarrow Color$. This is inspired by Luke Palmer's blog post (see \cite{Palmer08}). The definition of $Color$ is unimportant (until implementation) and depends on the color model we choose, for example whether we want to include transparency.

\subsubsection{Graph-Image Relation}
Every annotated graph has exactly one corresponding visual rendering (image). Thus, there is a *function* from annotated graphs to images: $\mathcal{AG} \rightarrow Image$. This function is the Graphui render function.

On the other hand, to allow easier visual editing we want to associate image regions to graph elements and annotations. In general this is not a function - the render function has no inverse. Example reasons are:

\begin{itemize}
\item No one-to-one relation between regions and elements - overlapping visual elements, such as crossing edges. 
\item Some image regions don't correspond to any element at all (empty regions). 
\end{itemize}

Furthermore, an image alone hardly suffices to find elements in the corresponding graph. We need the information that was used to render the image from the graph, not the image itself - and this information is exactly the visual representation. Consequently, a possible definition is (using the curried function form) for the Graphui image mapping function is: a partial function of the form $\mathcal{AG} \rightarrow \mathbb{R}^2 \rightarrow \mathcal{ID}$.

Given a specific annotated graph $(G,H)$, the image mapping function has only one argument, and is: $\mathbb{R}^2 \rightarrow ID_G$.


\subsubsection{The Reactive Part}
We know how to render graphs and we know how to relate areas in the rendered image back to graph elements and their annotations. To summarize what we have so far:

\begin{itemize}
\item Annotated graphs,
\item The render function: a function from annotated graphs to images,
\item The image mapping function: given an annotated graph it is a function from image coordinates to graph element id's.
\end{itemize}

What we are missing is the *reactive* part of the system, which deals with user interaction. We will use the FRP approach (see \cite{Elliott2009-push-pull-frp}) to model this part. The only way for the user to interact with the program is through the mouse and keyboard. We can model both using behaviors and events. We are going to implement Graphui using Yampa (\cite{hudak_arrows_2003}), which follows a slightly different model, but it is almost equivalent and we'll leave any neccesary "conversions" to the implementation. As a reminder, we are now discussing the semantic model only.

\textbf{Mouse and Keyboard}

\begin{itemize}
\item The mouse's position is modeled as a behavior, a function from time to coordinates: $Time \rightarrow \mathbb{R}^2$.
\item Mouse clicks are events, sequences of pairs $[(Time, E)]$ where $E$ contains the event data (which button, press or unpress, etc.)
\end{itemize}

Keyboard key presses are modeled as events, similar to mouse clicks.


\textbf{Animation}

To implement an animated visual interface, one of the system's output must be an animation. We define animation as a time-dependant function (behavior): $Time -> Image$.

\begin{figure}[h]
  \label{ref:graphui-design1}
  \begin{center}
    \includegraphics[scale=0.3]{design-test1.png}
  \end{center}
  \caption{Graphui Top-level design}
\end{figure}

\textbf{Graphui's Reactive Operation}

The user interacts by clicking on the rendered image (or other GUI elements on the screen) or by using the keyboard, to change the annotated graph. The change in the annotated graph in turn causes a new image to be rendered or some GUI elements to appear or disappear, and also may change the input handling of the program. For example, the user may enter a mode or menu in which some keys have different meanings or are disabled.

Following Yampa (\cite{hudak_arrows_2003}), we can describe our reactive system as a graph of "signal transformers", elements that transform time varying values. The top level design is as follows:

\begin{enumerate}
\item Input behaviors and events (such as mouse clicks and position) are interpreted and translated to GUI behaviors and events. For example, instead of speaking in terms of mouse clicks we want terms such as: button pressed/released, focus received, etc.
\item The GUI behaviors and events are used to calculate changes on the annotated graph or on the state of the GUI system.
\item The new annotated graph (or updated GUI state) affects what is displayed on the screen.
\end{enumerate}

For feedback as shown in \ref{ref:graphui-design1}, Yampa offers a delayed switching mechanism which ensures that the result of the computation that is fed-back is used in the "infinitisemal" future, and not again in the current step. 

\subsection{Implementation}
After learning to use Haskell and Yampa, the implementation of Graphui \emph{itself} was more or less straightforward following the design described above. Animation was not implemented - it turned out to be a rather complicated task using Yampa's switching primitives. The source code is available at http://github.com/sinelaw/graphui.

\subsection{Conclusions after writing the Graphui prototype}
The main challenge when implementing Graphui was learning to use Yampa, and learning to program in Haskell in general. Yampa's documentation is out of date, the library itself is messy and contains many redundancies, and all work on it seems to have stopped two or three years ago. Recent work on Yampa is mostly research-oriented regarding ways to re-design the library. 

My conclusion is that despite Yampa being a \emph{relatively} mature FRP library, it lacks greatly on the semantic clarity front. FRP is all about precision in the semantic model, and the disadvantage of Yampa in this regard is too great. It is possible the the disadvantage lays mainly in documentation issues (no clear description of the semantics is given anywhere) but as it is, the library does not represent the direction I would like to pursue under the title of FRP. Unfotunately no other FRP library that's sufficiently powerful exists to date.\footnote{Although two potential contenders for \emph{testing} purposes have lately been released: Elerea (eventless reactivity) and Peakachu, both available on http://hackage.haskell.org/}

Consequently, I have decided to implement a minimal library that will support only the primtives required by my project. In addition I have explored one of the question that arises when designing FRP semantics in Section \ref{sec:behave}.

\section{Gradual Accumulation of Memory}
\label{sec:behave}

\subsection{About this section}
This section was originally written as a separate (unpublished) report on the subject of arbitrary time access in FRP semantics. The title was ``Behavioral Amnesia: Gradual Accumulation of Memory for Temporal Values'', and the following paragraph served as the abstract:

\begin{quotation}
It's impossible to tell the future. Furthermore, in our physical reality, there is no way to access arbitrary events (or phenomena) in the past. We must store information in real-time if we want to use it later. Functional Reactive Programming (FRP) aims to supply a semantically simple and precise model for programming temporally reactive systems. This short report is about an attempt to form a semantic model for FRP that includes a restriction on arbitrary access in time. We explore the idea of realistic accumulation of memory by considering different classes of time dependent values. Implementation issues (which may turn out to be critical) are purposely ignored.
\end{quotation}

\subsection{Introduction}
As a programmer experienced mainly in imperative languages, I am still regularly amazed by the simplicity and elegance that functional programming offers in general, and that FRP (Functional Reactive Programming) seems to promise in particular. However, awe and amazement are no replacement for comprehension. The question ``What is FRP?'' still has no clear answer in my mind. Having read a little about FRP (\cite{ElliottHudak97:Fran}, \cite{nilsson_functional_2002}, \cite{courtney_yampa_2003}, \cite{hudak_arrows_2003}, \cite{Elliott2009-push-pull-frp}) and several blog posts, and after discussing FRP with different people from various different angles, I am still confused. FRP seems to mean several different things, and I like when definitions are precise. So how should we define FRP? Lately, following insights shared by Conal Elliott and others, I've realized that the essence of FRP should be summarized by at least the two following notions:
\begin{itemize}
\item \emph{Semantic precision} and clarity, as manifest by the denotational approach to design (see \cite{elliott_denotational_2009}).
\item \emph{Temporality}, or more specifically a functionally pure, referentially transparent and composable approach to temporally changing values. Time, as in real life, is continuous.\footnote{In our normal life it is. I'm disregarding the possibility of amazingly short time quanta that quantum physics introduces.} For a starting point about the reasons for working with continuous time, see \cite{elliott_program_time_2010}.
\end{itemize}
Elliott suggested an alternative name for FRP: ``Functional \emph{Temporal} Programming''.\footnote{With an unfortunate acronym - FTP.} For a paradigm that is centered on the above two concepts, I suggest also ``\emph{Denotational Temporal} Programming''. I'm not sure that these concepts are what people mean when they talk about FRP. If yes, then ``denotational-temporal'' can be used to clarify what FRP is about. If it \emph{isn't} what people mean, then I don't know what they do mean. In any case, in this section FRP means an approach that concentrates on temporally changing values and denotational design. With this point cleared up we may proceed to the issue at hand.

\subsection{Remembering and forgetting}
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

\subsection{Divide and Conquer}
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

\subsubsection{Discrete time}
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

\subsubsection{Continuous time, discrete value}
Once we enter the domain of continuous time, we can no longer meaningfully discuss ``the last defined time point''. We have shown how our attempted definition of infinitesimal time delay becomes problematic, but the problem was based on the continuity property. We are now discussing temporal values that have discrete value (Definition \ref{def:discrete-value}), and therefore continuity is impossible. Our temporal values are step functions, where the value suddenly changes at some points in time. We can then construct a list of those steps, and pair each new value with the time of the step. In this fashion we again end up with an ordered list of pairs $(Time,a)$. Therefore the definition of \emph{scanlT} used in the discrete-time case above can be used here too, except that here we work on the list of steps rather than the list of defined time points.

\subsubsection{Continuous time, non-discrete value}
Finally, we have to deal with temporal values of continuous time and non-discrete value. This means that in a finite time interval the temporal value may change at an infinite number of time points. How can we define \emph{scanlT} in a way that makes sense in the case of non-discrete changes in value? So far we've managed by choosing \emph{scanlT} to take a function of type $(Time,a) \rightarrow (Time,b) \rightarrow (Time,b)$, and run that function through a list of pairs, $[(Time,a)]$. With non-discrete value, however, between every two time points there is another in which the function may change its value. It may be possible to define a list of step values as before, but it will be ``infinitely dense'' and the time value of one pair will be the same as the time value of the next pair.

How can we deal with this infinitely confusing sequence?


\subsection{The Generalized Memory Accumulator}
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


\subsection{Food for thought}

\subsubsection{Time delay}

Time delay is problematic. We could allow the function passed into \emph{scanlT} to output the time value of each output it produces (output a time-value pair instead of just a value), but that opens the door to setting values at arbitrary times - exactly the problem we avoided by disallowing outputting the time. Also, time delay seems to require infinite memory for the continuous-time case. Despite these problems, time delay seems to be a valid operation - after all, it is both linear and time-invariant. Time delay can be performed via convolution with an impulse (dirac delta) placed at a non-zero time, and we have already shown that convolution is possible (because intergration is possible). However, the impulse is not really a function and thus the convolution integral in this case is no more (or less) than mathematical trickery. The best we can do is model the impulse as a limit on a constant energy signal, one which in the limit is concentrated at one time point. We end up using two limits - the integration limit and another for the convolving impulse function - something our model does not support.

Thus, because of its requirement for infinite memory and for the ability to write to arbitrary times, and despite being a linear, time-invariant operation, time delay is not neccesarily something we want to allow within our model. One consequence of this conclusion is that not all operations that are both linear and time-invariant are allowed in our model, despite belonging to a very limited class of operations.

Yet, in some intuitive sense, time delay seems like a realistic operation, one that we experience. We must once again turn to reality for ideas. How does time delay work in the real world? Apparently delays are due to reality having not only time, but also \emph{space}. In reality, we may delay information by transmitting it to a different location, an operation that must take time.\footnote{Due to the relativistic limitation of finite velocity, but also on the simpler level of us never experiencing delay-less transmission on a day-to-day basis.} FRP in general, and our proposed model in particular has no equivalent concept. This difference between our model and reality hints that we may be missing something. At the time of writing, this was an open question.

\subsubsection{Band-limited signals}
\label{sec:bandlimit}
We made an effort to deal with the continuous-time, non-discrete-value case. A point to consider is whether for some temporal values, sampling is sufficient. Recall Nyquist's theorem, which states that every signal (a function of time, specifically $\mathbb{R} \rightarrow \mathbb{R}$) whose Fourier transform is zero outside some finite interval, can be sampled and later reconstructed exactly. The condition is that the sampling rate be greater than twice the highest frequency in the signal. Signals satisfying the aforementioned condition are said to be \emph{band-limited}, and all the signals (temporal values) we normally deal with are band-limited. Therefore, apparently we can simply sample our continuous-time temporal values at some sufficiently high sampling frequency, and the samples will contain (and indeed do contain) all the necessary information about the signal, in a discrete-time equivalent form. However, ideal reconstruction\footnote{Shannon interpolation, if sampling is uniformly spaced.} from samples to continuous-time signals is \emph{not} causal! This means that we can't meaningfully say that Nyquist sampling represents exactly the original signal, if future samples are not all known.

\subsubsection{Computability and continuous functions}
As explained in \cite{bauer_sometimes_2007}, computable functions are all continuous. Continuous functions can be approximated to arbitrary precision, as the precision of the function's argument approaches infinite precision. On the other hand, non-continuous functions do not have this property. Consider a step function such as $sign(x)$, which is $-1$ for $x<0$ and $1$ at $x \ge 0$. To know the value of the function in the neighborhood of $0$ even at the ``rough'' precision of just knowing whether the result is closer to $-1$ or to $1$, we need to know the argument at infinite precision. For example, if the argument's digits are $-0.000000\ldots$, we need to know ``till the end'' whether the number is really just \emph{zero}, or whether there's a $1$ somewhere that makes it a negative number. Thus, to know anything at all about the function's value around zero we may need infinite information about the exact location. How, if at all, should this fact alter our model? Do we need to assume that all temporal values are continuous (eliminating the class of ``step functions'' of continuous-time completely)?

\subsection{Conclusion - Section on Gradual Accumulation of Memory}
In this section, we have discussed the following points:
\begin{itemize}
\item What should (or does) FRP mean? The point is apparently denotational design of a framework for temporal systems.
\item The idea that FRP should follow the realistic limit on arbitrary access in time.
\item An attempt to define an operation that makes it possible to compute various temporal functions with memory, without using access to values at arbitrary time points.
\end{itemize}
Finally we have mentioned a few open questions (for me at least) relating to the main discussion. It is my hope that this short section will inspire more rigorous, deeper insights into FRP by the readers.


\section{Binding Haskell to OpenCV, and the Processor module}
\label{sec:opencv}

One of the requirements for this project is an ability to process video inside the Haskell language. To this end I have created two Haskell ``cabal packages'' (a distribution format): HOpenCV, and cv-combinators. 

\subsection{Package: HOpenCV}
The HOpenCV package is a low-level Haskell binding to OpenCV. The term ``low-level binding'' in Haskell usually means an ability to call the external library's (in this case, OpenCV's) functions from Haskell as we would call them from C. This function-wrapping is exactly what HOpenCV is about. To make things a little bit nicer for Haskell users, HOpenCV supplies a thin wrapping interface for some of the functions (such as when the function requires passing a double pointer). 

Binding Haskell to OpenCV was done using manually written code that uses Haskell FFI (Foreign Function Interface). To make things easier a C-side thin wrapper is used in some cases. HOpenCV currently binds only a small part of the huge set of functions that OpenCV provides. The library has been tested minimally - almost all of the bound OpenCV functions have been tested succesfully, albeit manually. The library is currently ~400 lines of Haskell and FFI code, plus ~120 lines of C code.

The complete code and some documentation for HOpenCV has been published on the public Haskell package repository, at http://hackage.haskell.org/package/HOpenCV-0.11

Finally, a small test program that demonstrates edge detection from a live camera capture and on-screen display was implemented using HOpenCV. It is reproduced here (see Figure \ref{code:Test}) to show how the library is used. Specifically this example demonstrates the imperative (sequential) nature of HOpenCV, which provides motivation for the implementation of cv-combinators, as described in Subsection \ref{subsec:cv-comb}.

\floatstyle{boxed}  \restylefloat{figure}
\begin{figure}[h]
\begin{code}
module Main where

import Foreign.Ptr
import Foreign.ForeignPtr
import Foreign.C.Types

import AI.CV.OpenCV.CxCore
import AI.CV.OpenCV.CV
import AI.CV.OpenCV.HighGui

import Control.Monad(when)

showFrames :: CInt -> Ptr IplImage -> Ptr CvCapture -> IO ()
showFrames winNum targetImage cvcapture  = do
  frame <- cvQueryFrame cvcapture 
  cvConvertImage (fromArr frame) (fromArr targetImage) 0
  calcFrame targetImage
      where calcFrame targetSmall = do
              cvResize targetImage targetSmall CV_INTER_LINEAR
              cvCanny targetSmall targetSmall 30 190 3
              showImage winNum targetSmall
              key <- waitKey 5
              when (key == -1) (showFrames winNum targetImage cvcapture)

  
processImages :: Ptr CvCapture -> IO ()
processImages capture = do
  frame <- cvQueryFrame capture
  let winNum = 0
  newWindow winNum True
  target <- createImageF (cvGetSize frame) 1 iplDepth8u
  withForeignPtr target (\target' -> showFrames winNum target' capture) 
    
main :: IO ()
main = do
  capture <- createCameraCaptureF 0
  withForeignPtr capture processImages
\end{code}
\caption{Test.hs - test program for HOpenCV}
\label{code:Test}
\end{figure}
\floatstyle{plain}  \restylefloat{figure}

\subsection{Package: cv-combinators}
\label{subsec:cv-comb}

The low-level library HOpenCV supplies an imperative, or sequential, interface to computer vision functions. For example, to perform edge detection we must:
\begin{enumerate}
\item Create the output window
\item Create the camera object
\item Allocate space for the output image
\item Repeatedly: query for a new frame from the camera, perform edge detection into the allocated target, and display the result.
\item Release all allocated resources.
\end{enumerate}

\subsubsection{The Processor Module}
The cv-combinators library provides a highly generic module, Processor, which allows constructing a functional interface for performing operations of the form: allocate-process-release.

The Processor module allows us to compose operations without minding the order of resource allocation and release. We can write code such as:
\begin{code}
a >>> b --< (c *** d)
\end{code}
where a, b, c and d are processors. This example is equivalent to passing connecting a's output to b's input, duplicating b's output and sending it into c and d in parallel.\footnote{The actual implementation does not parallelize operations in runtime (by utilizing multi-core, for example), but it's not a difficult task to add that feature due to the module's design.} In our project, the processors will be cameras, image processing tranformations, and outputs units.

The semantic model for a Processor is: 

\begin{code}
[[ Processor m a b ]] = a -> b
\end{code}

The idea is that the monad m is usually IO, and that a and b are usually pointers.
It is meant for functions that require a pre-allocated output pointer to operate.

\begin{itemize}
\item a, b = the input and output types of the processor (think $a \rightarrow b$)
\item m = monad in which the processor operates
\item x = type of internal state  
\end{itemize}

The arguments to the constructor are:

\begin{enumerate}
\item Processing function: Takes input and internal state, and returns new internal state.

\item Allocator for internal state (this is run only once): Takes (usually the first) input, and returns initial internal state.

\item Convertor from state x to output b: Takes internal state and returns the output.

\item Releaser for internal state (finalizer, run once): Run after processor is done being used, to release the internal state.
\end{enumerate}


The Processor data type is an instance of Category, Functor, Applicative and Arrow. These are very general typeclasses in the common Haskell library. It is out of the scope of this report to detail the interfaces that these typeclasses provide or to discuss their usefulness, but the mere fact that we instantiate them menas that we can automatically use any library that was designed for them on our own Processor data type. The code of the Processor module is appended in \ref{code:Processor}.


\subsubsection{The ImageProcessors Module}
Once I have succesfully implemented Processor, it was almost trivial to start wrapping various OpenCV primitives by combining HOpenCV with the composable power of the Processor module. We present here as an example wrapping, the one for cvCanny in Figure \ref{code:canny}

\floatstyle{boxed}  \restylefloat{figure}
\begin{figure}[h]
\begin{code}
canny :: Int  -- Threshold 1
         -> Int  -- Threshold 2
         -> Int  -- Size
         -> ImageProcessor
canny thres1 thres2 size = processor processCanny allocateCanny convertState releaseState
    where processCanny src (gray, dst) = do
            HighGui.cvConvertImage src gray 0 
            CV.cvCanny gray dst (fromIntegral thres1) (fromIntegral thres2) (fromIntegral size)
            return (gray, dst)
            
          allocateCanny src = do
            target <- CxCore.cvCreateImage (CxCore.cvGetSize src) 1 CxCore.iplDepth8u
            gray <- CxCore.cvCreateImage (CxCore.cvGetSize src) 1 CxCore.iplDepth8u
            return (gray, target)
            
          convertState = do return . snd
                            
          releaseState (gray, target) = do
            CxCore.cvReleaseImage gray
            CxCore.cvReleaseImage target
\end{code}
\caption{Wrapping cvCanny as a processor}[Wrapping cvCanny as a processor. Code taken from ImageProcessors.hs of the cv-combinators package]
\label{code:canny}
\end{figure}
\floatstyle{plain}  \restylefloat{figure}

The final result is beautifully simple to use. A test program that performs face detection and displays the result on a live window output was written using ImageProcessors. Compare the program in Figure \ref{code:imagproc-test}, which uses cv-combinators, to any other implementation that uses OpenCV: I challenge the reader to find a simpler one! The crucial line is the implementation of the main function, which is as simple as:
\begin{code}
main = runTillKeyPressed (camera 0 --< (second faceDetect) >>> drawRects >>> window 0) 
\end{code}

The function takes a camera, duplicates its output, feeds one of them through face detection and the other is left unchanged (``second'' does that). Then, the pair of outputs from faceDetect and the camera's untouched output are fed into drawRects, which draws rectangles around the faces. The end result is fed into a window.


\floatstyle{boxed}  \restylefloat{figure}
\begin{figure}[h]
\begin{code}
module Main where


import AI.CV.ImageProcessors

import qualified AI.CV.OpenCV.CV as CV
import qualified AI.CV.Processor as Processor
import AI.CV.Processor((--<))
import AI.CV.OpenCV.Types
import AI.CV.OpenCV.CxCore(CvRect(..), CvSize(..))

import Prelude hiding ((.),id)
import Control.Arrow
import Control.Category

faceDetect :: Processor.Processor IO PImage [CvRect]
faceDetect = haarDetect "path-to-cascade.xml" 1.2 3 CV.cvHaarDoCannyPruning (CvSize 50 50)
  
main :: IO ()
main = runTillKeyPressed (camera 0 --< (second faceDetect) >>> drawRects >>> window 0) 
\end{code}
\caption{Test module for cv-combinators, which performs face detection.}
\label{code:imagproc-test}
\end{figure}
\floatstyle{plain}  \restylefloat{figure}

\subsection{HOpenCV and cv-combinators: Conclusion}
The packages implemented are extensible, as general as can be, and simple to use. The code is available on hackage (http://hackage.haskell.org). It is my hope that these packages will serve the Haskell / computer vision community well and will mature in the future to a stable, comprehensive state. I have learnt a lot by implementing this initial version of the packages.

With these packages laid down as fundamentals I feel much more confident to proceed in the implementation of the robotic system using Haskell.


\section{Conclusion}
The project is behind the schedule as defined in the preliminary report, but so much progress has been made that it is hard to say that the project is advancing slowly. Rather, the amount of work was unanticipated, especially the suprise realization that Yampa is not a suitable framework for this project. I will continue to work on the tasks defined in the preliminary report.



\section{Source Code: The Processor Module}
\label{code:Processor}
\textbf{Note:} Most of the comments from the codes have been removed due to technical TeX problems. The full source code is available at http://github.com/sinelaw/cv-combinators.

\begin{code}
module AI.CV.Processor where

import Prelude hiding ((.),id)

import Control.Category
import Control.Applicative hiding (empty)
import Control.Arrow

import Control.Monad(liftM, join)

data Processor m a b where
    Processor :: Monad m => (a -> x -> m x) -> (a -> m x) -> (x -> m b) -> (x -> m ()) -> (Processor m a b)
    
processor :: (Monad m) =>
             (a -> x -> m x) -> (a -> m x) -> (x -> m b) -> (x -> m ())
          -> Processor m a b
processor = Processor

--  Chains two processors serially, so one feeds the next.
chain :: (Monad m) => Processor m a b'  -> Processor m b' b -> Processor m a b
chain (Processor pf1 af1 cf1 rf1) (Processor pf2 af2 cf2 rf2) = processor pf3 af3 cf3 rf3
    where pf3 a (x1,x2) = do
            x1' <- pf1 a x1
            b'  <- cf1 x1
            x2' <- pf2 b' x2
            return (x1', x2')
            
          af3 a = do
            x1 <- af1 a
            b' <- cf1 x1
            x2 <- af2 b'
            return (x1,x2)
            
          cf3 (_,x2) = do
            b <- cf2 x2
            return b
            
          rf3 (x1,x2) = do
            rf2 x2
            rf1 x1
  
-- A processor that represents two sub-processors in parallel (although the current implementation runs them sequentially, but that may change in the future)
parallel :: (Monad m) => Processor m a b -> Processor m c d -> Processor m (a,c) (b,d)
parallel (Processor pf1 af1 cf1 rf1) (Processor pf2 af2 cf2 rf2) = processor pf3 af3 cf3 rf3
    where pf3 (a,c) (x1,x2) = do
            x1' <- pf1 a x1
            x2' <- pf2 c x2
            return (x1', x2')
            
          af3 (a,c) = do
            x1 <- af1 a
            x2 <- af2 c
            return (x1,x2)
            
          cf3 (x1,x2) = do
            b  <- cf1 x1
            d <- cf2 x2
            return (b,d)
            
          rf3 (x1,x2) = do
            rf2 x2
            rf1 x1

forkJoin :: (Monad m) => Processor m a b  -> Processor m a b' -> Processor m a (b,b')
forkJoin (Processor pf1 af1 cf1 rf1) (Processor pf2 af2 cf2 rf2) = processor pf3 af3 cf3 rf3
    where pf3 a (x1,x2) = do
            x1' <- pf1 a x1
            x2' <- pf2 a x2
            return (x1', x2')
            
          af3 a = do
            x1 <- af1 a
            x2 <- af2 a
            return (x1,x2)
            
          cf3 (x1,x2) = do
            b  <- cf1 x1
            b' <- cf2 x2
            return (b,b')
            
          rf3 (x1,x2) = do
            rf2 x2
            rf1 x1


-------------------------------------------------------------
--   The identity processor: output = input. Semantically, [[ empty ]] = id
empty :: Monad m => Processor m a a
empty = processor pf af cf rf
    where pf _ = do return
          af   = do return
          cf   = do return
          rf _ = do return ()
               
instance Monad m => Category (Processor m) where
  (.) = flip chain
  id  = empty
  
instance Monad m => Functor (Processor m a) where
  -- This could have used fmap internally as a Type Class Morphism, but monads don't neccesary implement the obvious: fmap = liftM.
  fmap f (Processor pf af cf rf) = processor pf af cf' rf
    where cf' x = liftM f (cf x) 

--   Splits (duplicates) the output of a functor, or on this case a processor.
split :: Functor f => f a -> f (a,a)
split = (join (,) <\$>)

(--<) :: (Functor (cat a), Category cat) => cat a a1 -> cat (a1, a1) c -> cat a c
f --< g = split f >>> g
infixr 1 --<


instance (Monad m) => Applicative (Processor m a) where
  pure b = processor pf af cf rf
    where pf _ = do return
          af _ = do return ()
          cf _ = do return b
          rf _ = do return ()
            
  (<*>) (Processor pf af cf rf) (Processor px ax cx rx) = processor py ay cy ry
    where py a (stateF, stateX) = do
            f' <- pf a stateF
            x' <- px a stateX
            return (f', x')
            
          ay a = do
            stateF <- af a
            stateX <- ax a
            return (stateF, stateX)
            
          cy (stateF, stateX) = do
            b2c <- cf stateF
            b <- cx stateX
            return (b2c b)
            
          ry (stateF, stateX) = do
            rx stateX
            rf stateF
  
instance Monad m => Arrow (Processor m) where
  arr = flip liftA id
  (&&&) = forkJoin
  (***) = parallel
  first = (*** id)
  second = (id ***)
  
-------------------------------------------------------------
            
--   Runs the processor once: allocates, processes, converts to output, and deallocates.
run :: (Monad m) => Processor m a b -> a -> m b
run = runWith id

--   Keeps running the processing function in a loop until a predicate on the output is true.
-- Useful for processors whose main function is after the allocation and before deallocation.
runUntil :: (Monad m) => Processor m a b -> a -> (b -> m Bool) -> m b
runUntil (Processor pf af cf rf) a untilF = do
  x <- af a
  let repeatF y = do
        y' <- pf a y
        b <- cf y'
        b' <- untilF b
        if b' then return b else repeatF y'
  d <- repeatF x
  rf x
  return d


--   Runs the processor once, but passes the processing + conversion action to the given function.
runWith :: Monad m => (m b -> m b') -> Processor m a b -> a -> m b'
runWith f (Processor pf af cf rf) a = do
        x <- af a
        b' <- f (pf a x >>= cf)
        rf x
        return b'
\end{code}

\pagebreak

\bibliographystyle{IEEEtran}
\bibliography{refs}

\end{document}