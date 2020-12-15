N = csvread('test.csv');
k = 1;
num_picks = 2;
ranks = 1:4;
pick_number = 1;
teams = 2;
players = [];
% pick, x, y, z

alpha = 1;
% SET VARIABLES
beta = ones(21, 1) * 50;
gamma = zeros(5, 1);
pos_lim = ones(5, 1) * 5;
[n, ~] = size(N);
pos = N(:, 1);
est_score = N(:, 2);
est_score = repmat(est_score, 21);
est_score_f = est_score(:, 1);
est_score = est_score(1:n, :);
[num_players, ~] = size(players);
opp_players = 1:n;
non_opp_players = [ranks; players];
opp_players(non_opp_players) = [];
opp_players_cell = num2cell(opp_players);
opp_players_cell(~cellfun('isempty', opp_players_cell));
opp_players = cell2mat(opp_players_cell);
[num_opp_players, ~] = size(opp_players);

% objective function
f = [est_score_f; zeros(n, 1); ones(21, 1)];
f = f .* -1;

num_constraints = 21 + 21 * n + 21 * 5 + 5 + num_picks - k + num_players + num_opp_players;
num_vars = n * 21 + n + 21;

% lhs coefficients
A = zeros(num_constraints, num_vars);

% rhs coefficients
b = zeros(num_constraints, 1);

% 1st constraint coefficients
row = 1;
for k_bar = k+1:num_picks
    for i = 1:n
        % find overall picks
        nk = 0;
        nk_bar = 0;
        if mod(k, 2) == 1
            nk = pick_number + (k - 1) * teams;
        else
            nk = teams * k - pick_number + 1;
        end
        if mod(k_bar, 2) == 1
            nk_bar = pick_number + (k_bar - 1) * teams;
        else
            nk_bar = teams * k_bar - pick_number + 1;
        end
        if ranks(i) <= alpha * (nk_bar - nk)
            A(row, n * 21 + i) = 1;
        end
    end
    b(row) = k_bar - k;
    row = row + 1;
end

% 2nd constraint coefficients
for j = 1:5
    for i = 1:n
        if pos(i) == j
            A(row, n * 21 + i) = -1;
        end
    end
    b(row) = -1 * gamma(j);
    row = row + 1;
end

% 3rd constraint coefficients
for j = 1:5
    for t = 1:21
        for i = 1:n
            if pos(i) == j
                A(row, i + n * (t - 1)) = 1;
            end
        end
        b(row) = pos_lim(j);
        row = row + 1;
    end
end

% 4th constraint coefficients
for t = 1:21
    for i = 1:n
        A(row, i + n * (t - 1)) = 1;
        A(row, n * 21 + i) = -1;
        row = row + 1;
    end
end

% 5th constraint coefficients
for t = 1:21
    A(row, n * 21 + n + t) = 1;
    for i = 1:n
        A(row, i + n * (t - 1)) = -1 * est_score(i, t) / beta(t);
    end
    row = row + 1;
end

% 6th constraint coefficients
for i = players
    A(row, n * 21 + i) = -1;
    b(row) = -1;
    row = row + 1;
end

% 7th constraint coefficients
for i = opp_players
    A(row, n * 21 + i) = 1;
    b(row) = 0;
    row = row + 1;
end

intcon = 1:numel(f);
lb = zeros(numel(f), 1);
ub = ones(1, numel(f));
Aeq = zeros(1, numel(f));
beq = 0;

results = intlinprog(f, intcon, A, b, Aeq, beq, lb, ub);
x = results(1:21 * n);
y = results(21 * n + 1:21 * n + n);
z = results(21 * n + n + 1:end);
pick = find(y, 1)