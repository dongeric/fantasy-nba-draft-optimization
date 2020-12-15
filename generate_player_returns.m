function [player_returns] = generate_player_returns(player_stats)
player_returns = zeros(length(player_stats), 2);

% Player positions
player_returns(:, 1) = player_stats(:, 1);

% This is an expected return calculation based on previous data
avg_pick = player_stats(:, 2);
exp_3pts = player_stats(:, 9);
rebounds = player_stats(:, 10);
assists = player_stats(:, 11);
steals = player_stats(:, 12);
blocks = player_stats(:, 13);
points = player_stats(:, 14);
fg_percent = player_stats(:, 7);
ft_percent = player_stats(:, 8);

player_returns(:, 2) = exp_3pts / 1.33 + rebounds / 6.12 + ...
                       assists / 3.69 + steals / 1.17 + blocks / 0.69 + ...
                       points / 16.27 + fg_percent / 0.47 + ft_percent / 0.78;
end