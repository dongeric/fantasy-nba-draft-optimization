% Read player stats
all_player_stats = csvread('PlayerStats.csv', 1, 3);

% This is a matrix containing player position and expected points per week
all_player_returns = generate_player_returns(all_player_stats);
num_total_players = length(all_player_returns);
all_player_returns = [all_player_returns cumsum(ones(num_total_players, 1))];

% Global Constants
draft_total = 10; % Number of players on team
num_participants = 12; % Number of participants in the draft
pick_number = 4; % The pick the player has in the first round

% Set variables that will change with each loop
num_drafted = 0; % number of players drafted so far
selected_players = []; % location of each player in original CSV file
curr_pick = pick_number; % The current pick that the player has 
num_taken = 0; % The number of players that have been removed from the draft thus far

% Draft people that are selected before our player can pick:
remaining_players = all_player_returns(pick_number:end, :);
num_taken = pick_number - 1;


% Simulate all picks but the last
while(num_drafted < draft_total)
    % Step 1: Pick a player from the remaining players
    
    % Inputs : 
    %    All players, players drafted so far on our team, estimated
    %    score, current pick number, total team size, unselected players,
    %    original draft pick, number of people drafting
    
    % Output: 
    %    The player index of from the truncated matrix file
    [pick, ~, ~, ~] = kth_draft_pick(all_player_returns, curr_pick, draft_total, ...
        pick_number, num_participants, selected_players, remaining_players); % CHANGE AS NEEDED
    
    % Step 2: Add that pick to our team
    % Order matters here
    num_drafted = num_drafted + 1;
    selected_players(num_drafted) = pick;
    
    % Step 3: Eliminate that pick from contention:
    relative_pick = find(remaining_players(:, 3) == pick);
    if (relative_pick == 1) 
        % No need to concatenate if we had the first player
        remaining_players = remaining_players(2:end, :);
    else
        % Otherwise, take the players above and below and concat
        remaining_players_above = remaining_players(1:relative_pick - 1, :);
        remaining_players_below = remaining_players((relative_pick + 1) : end, :);
        
        remaining_players = ...
                vertcat(remaining_players_above, remaining_players_below);
    end
    num_taken = num_taken + 1;
    
    % Step 4: Remove players who are "drafted" until the next pick
    if(mod(num_drafted, 2) == 1) 
        pick_difference = 2 * (draft_total - pick_number);
    else
        pick_difference = 2 * (pick_number - 1);
    end
    remaining_players = remaining_players(pick_difference + 1:end, :); 
    num_taken = num_taken + pick_difference;
    curr_pick = curr_pick + pick_difference;
     
end

% Simulate the last pick, which will also provide a schedule
[pick, x, y, z] = kth_draft_pick(all_player_returns, curr_pick, draft_total, ...
        pick_number, num_participants, selected_players, remaining_players);
selected_players(num_drafted) = pick;

player_names = readtable('PlayerStats.csv');
player_names = table2array(player_names(:, 2));
roster = player_names(selected_players);
fprintf('You had the %dth draft pick\n', pick_number);
disp('Your optimal team is:')
disp(roster)
