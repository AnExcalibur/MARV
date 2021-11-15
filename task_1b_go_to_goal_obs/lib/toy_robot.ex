defmodule ToyRobot do
  # max x-coordinate of table top
  @table_top_x 5
  # max y-coordinate of table top
  @table_top_y :e
  # mapping of y-coordinates
  @robot_map_y_atom_to_num %{:a => 1, :b => 2, :c => 3, :d => 4, :e => 5}

  @doc """
  Places the robot to the default position of (1, A, North)

  Examples:

      iex> ToyRobot.place
      {:ok, %ToyRobot.Position{facing: :north, x: 1, y: :a}}
  """
  def place do
    {:ok, %ToyRobot.Position{}}
  end

  def place(x, y, _facing) when x < 1 or y < :a or x > @table_top_x or y > @table_top_y do
    {:failure, "Invalid position"}
  end

  def place(_x, _y, facing)
  when facing not in [:north, :east, :south, :west]
  do
    {:failure, "Invalid facing direction"}
  end

  @doc """
  Places the robot to the provided position of (x, y, facing),
  but prevents it to be placed outside of the table and facing invalid direction.

  Examples:

      iex> ToyRobot.place(1, :b, :south)
      {:ok, %ToyRobot.Position{facing: :south, x: 1, y: :b}}

      iex> ToyRobot.place(-1, :f, :north)
      {:failure, "Invalid position"}

      iex> ToyRobot.place(3, :c, :north_east)
      {:failure, "Invalid facing direction"}
  """
  def place(x, y, facing) do
    {:ok, %ToyRobot.Position{x: x, y: y, facing: facing}}
  end

  @doc """
  Provide START position to the robot as given location of (x, y, facing) and place it.
  """
  def start(x\\1, y\\:a, facing\\:north) do
    ###########################
    ## complete this funcion ##
    ###########################
    place(x,y,facing)
  end

  def stop(_robot, goal_x, goal_y, _cli_proc_name) when goal_x < 1 or goal_y < :a or goal_x > @table_top_x or goal_y > @table_top_y do
    {:failure, "Invalid STOP position"}
  end

  @doc """
  Provide STOP position to the robot as given location of (x, y) and plan the path from START to STOP.
  Passing the CLI Server process name that will be used to send robot's current status after each action is taken.
  Spawn a process and register it with name ':client_toyrobot' which is used by CLI Server to send an
  indication for the presence of obstacle ahead of robot's current position and facing.
  """
  def helper(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state)do
    {robot,state}=yadjust(robot,goal_x,goal_y,state)
    {robot,state}=ytravel(robot,goal_x,goal_y,state)
    {robot,state}=xadjust(robot,goal_x,goal_y,state)
    {robot,state}=xtravel(robot,goal_x,goal_y,state)
    cond do
     (x==goal_x) && (y==goal_y)->
       {:ok}
     (x!=goal_x) || (y!=goal_y)->
 	helper(robot,goal_x,goal_y,state)
    end  
  end
 
  def stop(robot, goal_x, goal_y, cli_proc_name) do
    ###########################
    ## complete this funcion ##
    ###########################
    parent=self()
    Process.register(parent,:client_toyrobot)
    state=send_robot_status(robot,:cli_robot_state)
    {x,y,_}=report(robot)
    helper(robot,goal_x,goal_y,state)
    
    
    
    
  end
  def xadjust(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     #IO.puts(f)
     cond do
      x==goal_x->
        {robot,state}
      x<goal_x->
       cond do
         f==:east->
          {robot,state}
         f!=:east && f==:north->
          robot=right(robot)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          state=send_robot_status(robot,:cli_robot_state)
          xadjust(robot,goal_x,goal_y,state)
         f!=:east && f==:south->
          robot=left(robot)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          state=send_robot_status(robot,:cli_robot_state)
          xadjust(robot,goal_x,goal_y,state)
         f!=:east ->
          robot=left(robot)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          state=send_robot_status(robot,:cli_robot_state)
          xadjust(robot,goal_x,goal_y,state)
       end
      x>goal_x->
       cond do
         f==:west->
          {robot,state}
         f!=:west && f==:north->
          robot=left(robot)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          state=send_robot_status(robot,:cli_robot_state)
          xadjust(robot,goal_x,goal_y,state)
         f!=:west && f==:south->
          robot=right(robot)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          state=send_robot_status(robot,:cli_robot_state)
          xadjust(robot,goal_x,goal_y,state)
         f!=:west->
          robot=right(robot)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          state=send_robot_status(robot,:cli_robot_state)
          xadjust(robot,goal_x,goal_y,state)
       end
     end
        
     
  end
  def yadjust(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     #IO.puts(f)
     cond do
      y==goal_y->
       {robot,state}
      y<goal_y-> 
       cond do
         f==:north->
          {robot,state}
         f!=:north && f==:east->
          robot=left(robot)
          state=send_robot_status(robot,:cli_robot_state)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          yadjust(robot,goal_x,goal_y,state)
         f!=:north && f==:west->
          robot=right(robot)
          state=send_robot_status(robot,:cli_robot_state)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          yadjust(robot,goal_x,goal_y,state)
         f!=:north->
          robot=left(robot)
          state=send_robot_status(robot,:cli_robot_state)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          yadjust(robot,goal_x,goal_y,state)
       end
     y>goal_y->
       cond do
         f==:south->
          {robot,state}
         f!=:south && f==:west->
          robot=left(robot)
          state=send_robot_status(robot,:cli_robot_state)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          yadjust(robot,goal_x,goal_y,state)
         f!=:south && f==:east->
          robot=right(robot)
          state=send_robot_status(robot,:cli_robot_state)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          yadjust(robot,goal_x,goal_y,state)
         f!=:south->
          robot=left(robot)
          state=send_robot_status(robot,:cli_robot_state)
          #{_,_,f}=report(robot)
          #IO.puts(y)
          yadjust(robot,goal_x,goal_y,state)
       end
     end
  end
  def yhandleobs_ntive(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     cond do
       state && f==:south->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        yhandleobs_ntive(robot,goal_x,goal_y,state)
       state && f==:west->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        yhandleobs_ntive(robot,goal_x,goal_y,state)
       state && f==:west->
        robot=left(robot)
        state=send_robot_status(robot,:cli_robot_state)
        yhandleobs_ntive(robot,goal_x,goal_y,state)
       true->
        robot=move(robot)
    	state=send_robot_status(robot,:cli_robot_state)
    	{robot,state}=yadjust(robot,goal_x,goal_y,state)
    	{robot,state}
     end
  end
  
  def yhandleobs_ptive(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     cond do
       state && f==:north->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        yhandleobs_ptive(robot,goal_x,goal_y,state)
       state && f==:east->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        yhandleobs_ptive(robot,goal_x,goal_y,state)
       state && f==:west->
        robot=left(robot)
        state=send_robot_status(robot,:cli_robot_state)
        yhandleobs_ptive(robot,goal_x,goal_y,state)
       true->
        robot=move(robot)
    	state=send_robot_status(robot,:cli_robot_state)
    	{robot,state}=yadjust(robot,goal_x,goal_y,state)
    	{robot,state}
    end
  end
  
  
  def xhandleobs_ptive(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     cond do
       state && f==:east->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        xhandleobs_ptive(robot,goal_x,goal_y,state)
       state && f==:north->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        xhandleobs_ptive(robot,goal_x,goal_y,state)
       state && f==:south->
        robot=left(robot)
        state=send_robot_status(robot,:cli_robot_state)
        xhandleobs_ptive(robot,goal_x,goal_y,state)
       true->
	 robot=move(robot)
	 state=send_robot_status(robot,:cli_robot_state)
	 {robot,state}=xadjust(robot,goal_x,goal_y,state)
	 {robot,state}
    end
  end
  def xhandleobs_ntive(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     cond do
       state && f==:west->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        xhandleobs_ntive(robot,goal_x,goal_y,state)
       state && f==:south->
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        robot=right(robot)
        state=send_robot_status(robot,:cli_robot_state)
        xhandleobs_ntive(robot,goal_x,goal_y,state)
       state && f==:north->
        robot=left(robot)
        state=send_robot_status(robot,:cli_robot_state)
        xhandleobs_ntive(robot,goal_x,goal_y,state)
       true->
        robot=move(robot)
        state=send_robot_status(robot,:cli_robot_state)
        {robot,state}=xadjust(robot,goal_x,goal_y,state)
        {robot,state}
    end
  end
  def xtravel(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     #IO.puts(x)
     cond do
       x==goal_x->
         {robot,state}
       x<goal_x->
        {robot,state}=xhandleobs_ptive(robot,goal_x,goal_y,state)
        xtravel(robot,goal_x,goal_y,state)
       x>goal_x->
        {robot,state}=xhandleobs_ntive(robot,goal_x,goal_y,state)
        xtravel(robot,goal_x,goal_y,state)
       
         
     end
  end
  def ytravel(%ToyRobot.Position{x: x,y: y,facing: f} = robot,goal_x,goal_y,state) do
     #IO.puts(y)
     cond do
       y==goal_y->
         {robot,state}
       y<goal_y->
         {robot,state}=yhandleobs_ptive(robot,goal_x,goal_y,state)
         ytravel(robot,goal_x,goal_y,state)
       y>goal_y->
         {robot,state}=yhandleobs_ntive(robot,goal_x,goal_y,state)
         ytravel(robot,goal_x,goal_y,state)
       
       
         
     end
  end

  @doc """
  Send Toy Robot's current status i.e. location (x, y) and facing
  to the CLI Server process after each action is taken.
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def send_robot_status(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot, cli_proc_name) do
    send(cli_proc_name, {:toyrobot_status, x, y, facing})
    # IO.puts("Sent by Toy Robot Client: #{x}, #{y}, #{facing}")
    listen_from_server()
  end

  @doc """
  Listen to the CLI Server and wait for the message indicating the presence of obstacle.
  The message with the format: '{:obstacle_presence, < true or false >}'.
  """
  def listen_from_server() do
    receive do
      {:obstacle_presence, is_obs_ahead} -> is_obs_ahead
    end
  end

  @doc """
  Provides the report of the robot's current position

  Examples:

      iex> {:ok, robot} = ToyRobot.place(2, :b, :west)
      iex> ToyRobot.report(robot)
      {2, :b, :west}
  """
  def report(%ToyRobot.Position{x: x, y: y, facing: facing} = _robot) do
    {x, y, facing}
  end

  @directions_to_the_right %{north: :east, east: :south, south: :west, west: :north}
  @doc """
  Rotates the robot to the right
  """
  def right(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_right[facing]}
  end

  @directions_to_the_left Enum.map(@directions_to_the_right, fn {from, to} -> {to, from} end)
  @doc """
  Rotates the robot to the left
  """
  def left(%ToyRobot.Position{facing: facing} = robot) do
    %ToyRobot.Position{robot | facing: @directions_to_the_left[facing]}
  end

  @doc """
  Moves the robot to the north, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: _, y: y, facing: :north} = robot) when y < @table_top_y do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) + 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the east, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: x, y: _, facing: :east} = robot) when x < @table_top_x do
    %ToyRobot.Position{robot | x: x + 1}
  end

  @doc """
  Moves the robot to the south, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: _, y: y, facing: :south} = robot) when y > :a do
    %ToyRobot.Position{robot | y: Enum.find(@robot_map_y_atom_to_num, fn {_, val} -> val == Map.get(@robot_map_y_atom_to_num, y) - 1 end) |> elem(0)}
  end

  @doc """
  Moves the robot to the west, but prevents it to fall
  """
  def move(%ToyRobot.Position{x: x, y: _, facing: :west} = robot) when x > 1 do
    %ToyRobot.Position{robot | x: x - 1}
  end

  @doc """
  Does not change the position of the robot.
  This function used as fallback if the robot cannot move outside the table
  """
  def move(robot), do: robot

  def failure do
    raise "Connection has been lost"
  end
end
