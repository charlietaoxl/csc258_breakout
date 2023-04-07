\documentclass{article}

%% Page Margins %%
\usepackage{geometry}
\geometry{
    top = 0.75in,
    bottom = 0.75in,
    right = 0.75in,
    left = 0.75in,
}

\usepackage{amsmath}
\usepackage{graphicx}
\usepackage{parskip}

\title{Assembly Project: Breakout}

% TODO: Enter your name
\author{Charlie Tao & Clark Zhang}

\begin{document}
\maketitle

\section{Instruction and Summary}

\begin{enumerate}

    \item Which milestones were implemented? 
    1, 2, 3, 4, 5

    \item How to view the game:
    % TODO: specify the pixes/unit, width and height of 
    %       your game, etc.  NOTE: list these details in
    %       the header of your breakout.asm file too!
    
    \begin{enumerate}

    \item Launch compiler of choice
    \item View bitmap and connect keyboard (depending on compiler)
    \item Compile and run! 'a' moves left, 'd' moves right, 'q' exits, 'p' pauses/unpauses the game. Enjoy!


    \end{enumerate}

    

\begin{figure}[ht!]
    \centering
    \includegraphics[width=0.3\textwidth]{pic_breakout_start.png}
    \caption{Level 1}
    \label{Instructions}
\end{figure}

\begin{figure}[ht!]
    \centering
    \includegraphics[width=0.3\textwidth]{pic_breakout_stage2.png}
    \caption{Level 2}
    \label{Instructions}
\end{figure}

\item Game Summary:
% TODO: Tell us a little about your game.
\begin{itemize}
\item Paddle moves left and right
\item Hit the ball to bounce on the blocks
\item The edges of the paddle bounce the ball to the left or right respectively. The middle bounces the ball upwards. 
\item The more bricks you hit, the faster the ball gets!
\item Once you reach a certain progress in the first stage, you move on to the next. 
\item Clear all the blocks! Good Luck!
\end{itemize}

    
\end{enumerate}

\section{Attribution Table}
% TODO: If you worked in partners, tell us who was 
%       responsible for which features. Some reweighting 
%       might be possible in cases where one group member
%       deserves extra credit for the work they put in.

\begin{center}
\begin{tabular}{|| c | c ||}
\hline
 Charlie Tao 1008251589 &  Clark Zhang 1008423421 \\ 
 \hline
 Drawing paddle & Drawing walls\\
 \hline
 Drawing bricks & Keyboard input\\
 \hline
 Keyboard response & Game loop\\ 
 \hline
 Moving Ball & Breaking Blocks\\ 
 \hline
 Collision & Refactoring\\
 \hline
 Milestone 5 & Milestone 4\\  
 \hline
\end{tabular}
\end{center}

% TODO: Fill out the remainder of the document as you see 
%       fit, including as much detail as you think 
%       necessary to better understand your code. 
%       You can add extra sections and subsections to 
%       help us understand why you deserve marks for 
%       features that were more challenging than they
%       might initially seem.
\section{Notable features}

\begin{enumerate}
    \item 5 EASY FEATURES DONE: Unbreakable brick, Ball speed up, Game pausing, Sounds, 3 Lives (amount is changeable in code)
    \item 3 HARD FEATURES DONE: Differing paddle bounce, Second level, Multiple hits to break bricks.
    \item COLLISION: Collision was definitely the most challenging part of this project compared to what it seemed. After many trials and differing attempts to implement collision, I finally came to a working method. 
    
    This method was to check only 3 pixels instead of all 8 pixels. This way, only the pixels that the ball passes through are checked, and the bounce is properly calculated upon hitting the block. The velocity of the bounce as well as its x and y positions were stored in a global Ball struct. By finding the negative of the velocity, the ball was able to bounce. Creating a robust collision system is what allowed the other features to be implemented easier. 
    
\end{enumerate} 

\end{document}
