struct Game {
mut:
	rolls        [21]int
	current_roll int
}

fn (mut g Game) roll(pins int) {
	g.rolls[g.current_roll] = pins
	g.current_roll++
}

fn (g Game) is_spare(first_in_frame int) bool {
	return g.rolls[first_in_frame] + g.rolls[first_in_frame + 1] == 10
}

fn (g Game) is_strike(first_in_frame int) bool {
	return g.rolls[first_in_frame] == 10
}

fn (g Game) next_two_balls_for_strike(first_in_frame int) int {
	return g.rolls[first_in_frame + 1] + g.rolls[first_in_frame + 2]
}

fn (g Game) next_ball_for_spare(first_in_frame int) int {
	return g.rolls[first_in_frame + 2]
}

fn (g Game) two_balls_in_frame(first_in_frame int) int {
	return g.rolls[first_in_frame] + g.rolls[first_in_frame + 1]
}

fn (mut g Game) score() int {
	mut score := 0
	mut first_in_frame := 0
	for frame in 0 .. 10 {
		if g.is_strike(first_in_frame) {
			score += 10 + g.next_two_balls_for_strike(first_in_frame)
			first_in_frame += 1
		} else if g.is_spare(first_in_frame) {
			score += 10 + g.next_ball_for_spare(first_in_frame)
			first_in_frame += 2
		} else {
			score += g.two_balls_in_frame(first_in_frame)
			first_in_frame += 2
		}
	}
	return score
}

//==========================================
fn (mut g Game) roll_many(n int, pins int) {
	for i in 0 .. n {
		g.roll(pins)
	}
}

fn (mut g Game) roll_spare() {
	g.roll(5)
	g.roll(5)
}

fn (mut g Game) roll_strike() {
	g.roll(10)
}

fn test_gutter_game() {
	mut g := Game{}
	g.roll_many(20, 0)
	assert 0 == g.score()
}

fn test_all_ones() {
	mut g := Game{}
	g.roll_many(20, 1)
	assert 20 == g.score()
}

fn test_one_spare() {
	mut g := Game{}
	g.roll_spare()
	g.roll(3)
	g.roll_many(17, 0)
	assert 16 == g.score()
}

fn test_one_strike() {
	mut g := Game{}
	g.roll_strike()
	g.roll(3)
	g.roll(4)
	g.roll_many(16, 0)
	assert 24 == g.score()
}

fn test_perfect_game() {
	mut g := Game{}
	g.roll_many(12, 10)
	assert 300 == g.score()
}
