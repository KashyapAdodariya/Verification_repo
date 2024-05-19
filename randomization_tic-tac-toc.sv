
`define N 3
typedef enum {CROSS=-1, EMPTY=0, CIRCLE=1} move_e; 
// This is the class that we will randomize.
class tictactoe;
  
  //Top most decision
  rand bit winning_game;
  
  //Second level decision vars
  rand bit draw_game;
  rand bit incomplete_game;
  rand int winD;
  
  //Third level decision vars
  rand bit[(2*`N+1):0] p1_wins;
  rand bit[(2*`N+1):0] p2_wins;
  
  //Fourth level decision vars
  rand move_e tic_tac[`N][`N];
  rand move_e tic_tac_t[`N][`N];
  rand int empty[`N][`N];
  rand int row_sum[`N];
  rand int col_sum[`N];
  rand int diag[`N];
  rand int diag_sum;
  rand int rdiag[`N];
  rand int rdiag_sum;
  rand int board_sum;
  rand int empty_sum;
  rand int intersection;


  //////////////////////////////////////
  //Top most decision - winning_game
  //////////////////////////////////////
  constraint tc1{
    solve winning_game before p1_wins, p2_wins,draw_game, winD, incomplete_game;
    winning_game dist {0:= 50, 1:=50};
  }
  
  /////////////////////////////////////////////////////////////
  //Second level decision - draw_game, 2d_win, incomplete_game
  /////////////////////////////////////////////////////////////
  constraint tc2{
    solve draw_game before p1_wins, p2_wins;
    solve winD before p1_wins, p2_wins;
    solve incomplete_game before p1_wins, p2_wins;
    draw_game dist {0:= 50, 1:=50};
    winD inside {[0:4]};
    winD dist {0:=20, 1:= 20, 2:=20, 3:=20, 4:=20};
    
    //Winning game cannot be draw game and vice versa
    winning_game == 1 -> draw_game == 0;
    draw_game == 1 -> winning_game == 0;
    
    //2D win can only happen in a winning game
    winning_game == 0 -> winD == 0;
    winning_game == 1 -> winD > 0;
    
    //Constraints on deciding which is incomplete game
    winning_game == 0 && draw_game == 0 -> incomplete_game == 1;
    winning_game==1 || draw_game==1 -> incomplete_game == 0;
  }
  
  /////////////////////////////////////////////////////////////
  //Third level decision - p1_wins, u2_wins
  /////////////////////////////////////////////////////////////
  constraint tc3{
    solve p1_wins before tic_tac, tic_tac_t, diag, rdiag, empty, row_sum, col_sum, diag_sum, rdiag_sum, board_sum, empty_sum;
    solve p2_wins before tic_tac, tic_tac_t, diag, rdiag, empty, row_sum, col_sum, diag_sum, rdiag_sum, board_sum, empty_sum;
    
 
 
    //General winning constraints
    $countones(p1_wins)+$countones(p2_wins)==winD;
    $countones(p1_wins)==winD || $countones(p2_wins)==winD;
    $countones(p1_wins[`N-1:0])<=1;
    $countones(p1_wins[2*`N-1:`N])<=1;
    $countones(p2_wins[`N-1:0])<=1;
    $countones(p2_wins[2*`N-1:`N])<=1;
    intersection inside {[0:`N-1]};
    solve intersection before p1_wins, p2_wins,draw_game, winD, incomplete_game; 
    
  
    if((winning_game==1) && (winD==3)){
      //(R,C,D) || (R,C,RD) || (`N odd, R, D, RD) || (`N odd, C, D, RD)
      $countones(p1_wins)==3 -> 
      ((p1_wins[intersection]== 1) && (p1_wins[`N+intersection]==1) && (p1_wins[2*`N]==1)) ||  
      ((p1_wins[intersection]== 1) && (p1_wins[2*`N-1-intersection]==1) && (p1_wins[2*`N+1]==1)) || 
      ((`N%2==1) && (intersection==((`N-1)/2)) && (p1_wins[intersection]== 1) && (p1_wins[2*`N]==1) && (p1_wins[2*`N+1]==1)) ||
      ((`N%2==1) && (intersection==((`N-1)/2)) && (p1_wins[`N+intersection]== 1) && (p1_wins[2*`N]==1) && (p1_wins[2*`N+1]==1));
      $countones(p2_wins)==3 -> 
      ((p2_wins[intersection]== 1) && (p2_wins[`N+intersection]==1) && (p2_wins[2*`N]==1)) ||  
      ((p2_wins[intersection]== 1) && (p2_wins[2*`N-1-intersection]==1) && (p2_wins[2*`N+1]==1)) || 
      ((`N%2==1) && (intersection==((`N-1)/2)) && (p2_wins[intersection]== 1) && (p2_wins[2*`N]==1) && (p2_wins[2*`N+1]==1)) ||
      ((`N%2==1) && (intersection==((`N-1)/2)) && (p2_wins[`N+intersection]== 1) && (p2_wins[2*`N]==1) && (p2_wins[2*`N+1]==1));
    }
    if((winning_game==1) && (winD==4)){
      $countones(p1_wins)== 4 ->
      (`N%2==1) && (intersection==((`N-1)/2)) && (p1_wins[intersection]== 1) && (p1_wins[`N+intersection]== 1) && (p1_wins[2*`N]==1) && (p1_wins[2*`N+1]==1);
      $countones(p2_wins)== 4 ->
      (`N%2==1) && (intersection==((`N-1)/2)) && (p2_wins[intersection]== 1) && (p2_wins[`N+intersection]== 1) && (p2_wins[2*`N]==1) && (p2_wins[2*`N+1]==1);
    }
  }
 
  ////////////////////////////////////////////////////////////////////////
  //Fourth level decision - tic_tac, row_sum, col_sum, diag_sum, rdiag_sum
  ////////////////////////////////////////////////////////////////////////
  constraint tc4{
    //Constraint various matrices, vectors etc
    foreach(tic_tac[i,j]){
      tic_tac_t[i][j] == tic_tac[j][i];
      i==j->diag[i]==tic_tac_t[i][j];
      i+j==`N-1->rdiag[i]==tic_tac_t[i][j];
      tic_tac[i][j]==0->empty[i][j]==1;
      tic_tac[i][j]!=0->empty[i][j]==0;
      
    }
      
    //Compute Row and Column sums  
    foreach(tic_tac[i]){
      tic_tac[i].sum()==row_sum[i];
      tic_tac_t[i].sum()==col_sum[i];
    }
      
    //Compute diag and reverse diag terms
    diag_sum  == diag.sum();
    rdiag_sum == rdiag.sum();
    
    //General Board Sum
    board_sum == row_sum.sum();
    board_sum >=-1;
    board_sum<=1;
    
    //Winning Board Sum
    $countones(p1_wins)>0 -> board_sum <=0;
    $countones(p2_wins)>0 -> board_sum >=0;

    //Winning Constraints
    foreach(p1_wins[i]){
      if(i<`N){
        (row_sum[i]==`N*CROSS) -> (p1_wins[i]==1);
        (p1_wins[i]==1) -> (row_sum[i]==`N*CROSS);
        (row_sum[i]==`N*CIRCLE) -> (p2_wins[i]==1);
        (p2_wins[i]==1) ->(row_sum[i]==`N*CIRCLE);
      }
      if((i>=`N) && (i<2*`N)){
        (col_sum[i-`N]==`N*CROSS) -> (p1_wins[i]==1);
        (p1_wins[i]==1) ->(col_sum[i-`N]==`N*CROSS);
        (col_sum[i-`N]==`N*CIRCLE) -> (p2_wins[i]==1);
        (p2_wins[i]==1) ->(col_sum[i-`N]==`N*CIRCLE);
      }
      if(i==2*`N){
        (diag_sum==`N*CROSS) -> (p1_wins[i]==1);
        (p1_wins[i]==1) -> (diag_sum==`N*CROSS);
        (diag_sum==`N*CIRCLE) -> (p2_wins[i]==1);
        (p2_wins[i]==1) -> (diag_sum==`N*CIRCLE);
      }
      if(i==2*`N+1){
        (rdiag_sum==`N*CROSS) -> (p1_wins[i]==1);
        (p1_wins[i]==1) -> (rdiag_sum==`N*CROSS);
        (rdiag_sum==`N*CIRCLE) -> (p2_wins[i]==1);
        (p2_wins[i]==1)->(rdiag_sum==`N*CIRCLE);
      }
    }

        
    //Draw & Incomplete Game constraints
    //Draw & Incomplete Games should also have no-win constraints which are taken care above
    empty_sum == empty.sum();
    incomplete_game == 1 -> empty_sum>0;
    draw_game == 1 -> empty_sum==0;

  }

  function string get_sym(move_e move);
      string s;
      if(move==CROSS) s = "X";
      if(move==CIRCLE) s = "0";
      if(move==EMPTY) s = "_";
      return s;
  endfunction: get_sym    

  // Print out the items.
  function void print();
    string s;
    $display("Printing tic-tac");
    $display("winning_game=%0d, winD=%0d, draw_game=%0d incomplete_game=%h p1_wins=%h p2_wins=%h intersection=%0d\n", winning_game, winD, draw_game, incomplete_game, p1_wins,p2_wins, intersection );
    foreach (tic_tac[i])begin
      s="";
      foreach (tic_tac[i][j])begin
        s = {s, " ", get_sym(tic_tac[i][j])};
      end
      $display(" %s", s);
    end
    
  endfunction
  
endclass

module test;
   tictactoe m_tictactoe;
  function void run;
    m_tictactoe = new();
    for (int i = 0; i < 10; i++) begin
      $display("RANDOMIZE %0d", i);
      m_tictactoe.randomize() with {//winD==2;
        //winning_game==1;
        //incomplete_game==1;
      };;
      m_tictactoe.print();
    end
  endfunction
  initial run();
endmodule
