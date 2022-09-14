class GamePlay{
	// game mode
	boolean set_available = true;
	String shake_mode;
	// game start animation
	int last_time;
	float readyGo_pos = -8400;
	boolean goPlay = true;
	boolean goText = false;
	boolean gameStart = false;
	// ring
	boolean ring_available = true;
	int last_ring = frameCount;
	int ring_count = 0;
	// coin 
	boolean coin_available = true;
	int last_coin = frameCount;
	// game flow
	boolean setFinalInfo = false;
	boolean gameEnd_available = false;
	GamePlay(){}
	void play(String mode){
		// Set level parameters
		if (set_available){
			set_available = false;
			switch(mode){
				case "easy":
					flying_speed_base = 60;
					shake_mode = "static";
					break;
				case "medium":
					flying_speed_base = 75;
					shake_mode = "slight";
					break;
				case "hard":
					flying_speed_base = 90;
					shake_mode = "strong";
					break;
			}
		}

		// Ready Go animation
		if (!gameStart){
			if (!goText){
				// "READY" text fly in
				pushMatrix();
				rotateY(-HALF_PI);
				fill(#ffffff);
				textFont(righteous);
				textSize(250);
				text("READY",width/2-textWidth("READY")/2,height/2,readyGo_pos);
				popMatrix();
				readyGo_pos += flying_speed*2;
				if (readyGo_pos >= 0) {
					readyGo_pos = -8400;
					goText = true;
				}
			} else {
				// "GO" text fly in
				pushMatrix();
				rotateY(-HALF_PI);
				fill(#ffffff);
				textFont(righteous);
				textSize(250);
				text("GO",width/2-textWidth("GO")/2,height/2,readyGo_pos);
				popMatrix();
				readyGo_pos += flying_speed*2;
				if (readyGo_pos >= -6000 && goPlay){
					goPlay = false;
					goPlayer.play();
					goPlayer.rewind();
				}
				if (readyGo_pos >= 200) {
					readyGo_pos = -8400;
					gameStart = true;
				}
			}

		// Game start
		} else {
			// Ring
			ring.generator();
			if (ring_available){
				last_ring = frameCount;
				if (ring.flyInExam() == 1){ // pass
					ring_available = false;
					ring_count++;
					statusPanel.score += 10;
					ring.colored(#84d971);
					ringPassPlayer.rewind();
					ringPassPlayer.play();
					// Game speed up if 5 times pass
					if (ring_count%4 == 0) flying_speed_base += 3;
				} else if(ring.flyInExam() == 2){ // fail
					ring_available = false;
					ring_count++;
					statusPanel.life--;
					ring.colored(#ff5e5e);
					if (statusPanel.life == 0) {
						setFinalInfo = true;
						deadPlayer.rewind();
						deadPlayer.play();
					} else {
						ringFailPlayer.rewind();
						ringFailPlayer.play();
					}
				} else if(ring.flyInExam() == 3){
					ring.colored(#ffc86c); // normal
				}
			} else if (frameCount - last_ring >= 10) ring_available = true;

			// Coin
			for (int i = 0; i < coins.length; i++){
				// give different type of coin
				int type = 0;
				if (i%10 == 0){
					coins[i].display(1);
					type = 1;
				}else if (i%3 == 0) {
					coins[i].display(2);
					type = 2;
				} else {
					coins[i].display(3);
					type = 3;
				}
				// Exam and score
				if (coin_available){
					last_coin = frameCount;
					if (coins[i].coinEatenExam() == 1){
						coin_available = false;
						if (type == 1) statusPanel.score += 4;
						else if (type == 2) statusPanel.score += 2;
						else if (type == 3) statusPanel.score += 1;
						coinPlayer.rewind();
						coinPlayer.play();
					}
				} else if (frameCount - last_coin >= 10) coin_available = true;
			}

			// Save to final info and end game
			if (setFinalInfo) {
				lastLevel = gameState;
				finalPage.score = statusPanel.score;
				if (!gameEnd_available){
					last_time = millis();
					gameEnd_available = true;
				} else {
					// stick lock
					stick_lock = true;
					if (millis() - last_time > 1000){
						gameEnd = true;
						stick_lock = false;
					}
				}
			}


		}

		// Windy Shake
		airplane.windyShake(shake_mode);

		// Airplane controls
		airplane.flyingControl(control_z,control_y);
		
	}
	void reset(){
		// airplane position
		control_z = width/2;
		control_y = height/2;
		// ready go animation reset
		goPlay = true;
		// game play reset
		set_available = true;
		last_time = 0;
		readyGo_pos = -8400;
		goText = false;
		gameStart = false;
		ring_available = true;
		last_ring = frameCount;
		ring_count = 0;
		coin_available = true;
		last_coin = frameCount;
		setFinalInfo = false;
		gameEnd_available = false;
		// airplane reset
		airplane.reset();
		// ring reset
		ring.reset();
		// coin reset
		for (int i = 0; i < coins.length; i++){
			coins[i].reset();
		}
		// scene reset
		scene.reset();
		// status panel reset
		statusPanel.reset();
	}
	
	
}