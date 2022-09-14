class SelectPage{
	PImage selectPageBg;
	PImage level_card;
	PImage level_card_1;
	PImage level_card_2;
	PImage level_card_3;
	PGraphics level_card_mask;
	boolean select_available = true;
	boolean enter_available = false;
	boolean level_entering = false;
	int select_focus = 0;
	SelectPage(){
		selectPageBg = loadImage("./images/selectPage_bg.jpg");
		level_card_1 = loadImage("images/card_1.png");
		level_card_2 = loadImage("images/card_2.png");
		level_card_3 = loadImage("images/card_3.png");
		level_card_mask = createGraphics(300,450);
		level_card_mask.beginDraw();
		level_card_mask.rect(0,0,300,450,20);
		level_card_mask.endDraw();
		level_card_1.mask(level_card_mask);
		level_card_2.mask(level_card_mask);
		level_card_3.mask(level_card_mask);
	}
	void display(){
		/* Logic: Select ---------------- */
		if (stick_right && select_available){
			last_stick = millis();
			select_available = false;
			if (select_focus >= 3) select_focus = 3;
			else select_focus++;
			// focus audio
			focusPlayer.rewind();
			focusPlayer.play();
		} else if (stick_left && select_available){
			select_available = false;
			last_stick = millis();
			if (select_focus <= 0) select_focus = 0;
			else select_focus--;
			// focus audio
			focusPlayer.rewind();
			focusPlayer.play();
		} else if (millis() - last_stick > 300) select_available = true;

		/* Logic: Enter ---------------- */
		if (!stick_up) enter_available = true; // avoid final to select entering
		if (select_focus == 3 && stick_up) exit();
		else if ((select_focus == 0 || select_focus == 1 || select_focus == 2) && stick_up && enter_available){
			enter_available = false;
			stick_lock = true; // lock stick when entering
			last_stick = millis();
			level_entering = true;
			// entering audio
			enterPlayer.rewind();
			enterPlayer.play();
		}

		/* Display: Background ---------------- */
		background(#000000);
		pushMatrix();
		rotateY(-HALF_PI);
		image(selectPageBg,0,0,width,height);
		popMatrix();

		/* Display: Game name ---------------- */
		pushMatrix();
		rotateY(-HALF_PI);
		fill(#52453a);
		textFont(righteous);
		textSize(100);
		text("Soar",width/2-textWidth("Soar")/2,160,0);
		fill(#52453a);
		textSize(32);
		text("Select a level to start!",width/2-textWidth("Select a level to start!")/2,240,0);
		popMatrix();

		/* Display: Three level cards ---------------- */
		for (int i = 0; i <= 2; i++){
			String level_text = "";
			if (i == 0){ // card 1
				level_card = level_card_1;
				level_text = "Easy";
			} else if (i == 1){ // card 2
				level_card = level_card_2;
				level_text = "Medium";
			} else if (i == 2){ // card 3
				level_card = level_card_3;
				level_text = "Hard";
			}
			pushMatrix();
			rotateY(-HALF_PI);
			// card image
			translate(430+380*i,300,0);
			if (select_focus == i){
				image(level_card,-10,-15,320,480);
			} else {
				image(level_card,0,0,300,450);
			}
			// frame
			strokeWeight(4);
			stroke(#ffffff);
			noFill();
			if (select_focus == i){
				strokeWeight(8);
				rect(-10,-15,320,480,20);
			} else rect(0,0,300,450,20);
			// text
			fill(#ffffff);
			textFont(righteous);
			if (select_focus == i){
				textSize(64);
				text(level_text,150-textWidth(level_text)/2,240,0);
			} else {
				textSize(56);
				text(level_text,150-textWidth(level_text)/2,240,0);
			}
			popMatrix();
		}
		
		/* Display: Exit button ---------------- */
		String exit_text = "Exit";
		pushMatrix();
		rotateY(-HALF_PI);
		translate(1680,936,0);
		// frame
		strokeWeight(4);
		stroke(#ffffff);
		if (select_focus == 3){
			fill(#ffffff);
		} else {
			noFill();
		}
		rect(0,0,160,64,80);
		textFont(righteous);
		textSize(32);
		if (select_focus == 3){
			fill(#52453a);
		} else {
			fill(#ffffff);
		}
		text(exit_text,(160-textWidth(exit_text))/2,42,0);
		popMatrix();
		
		/* Display: airplane---------------- */
		airplane.selectDisplay(select_focus,level_entering);
		
		/* Page BGM ---------------- */
		selectPagePlayer.play();
		if (selectPagePlayer.position()>=selectPagePlayer.length()) selectPagePlayer.rewind();
		if (level_selected == true){
			selectPagePlayer.rewind();
			selectPagePlayer.pause();
		}
	}
	void reset(){
		stick_lock = false;
		select_available = true;
		enter_available = false;
		level_entering = false;
		select_focus = 0;
	}
}

class FinalPage{
	PImage finalPageBg;
	int score;
	boolean select_available = true;
	boolean stick_available = true;
	boolean enter_available = false;
	int select_focus = 0;
	FinalPage(){
		finalPageBg = loadImage("./images/finalPage_bg.png");
	}
	void display(){
		
		/* Logic: Select ---------------- */
		if (stick_right && select_available){
			last_stick = millis();
			select_available = false;
			if (select_focus >= 1) select_focus = 1;
			else select_focus++;
			// focus audio
			focusPlayer.rewind();
			focusPlayer.play();
		} else if (stick_left && select_available){
			select_available = false;
			last_stick = millis();
			if (select_focus <= 0) select_focus = 0;
			else select_focus--;
			// focus audio
			focusPlayer.rewind();
			focusPlayer.play();
		} else if (millis() - last_stick > 300) select_available = true;

		/* Logic: Enter ---------------- */
		if (!stick_up) enter_available = true; // avoid levels to final entering
		// Play again
		if ((select_focus == 0 || select_focus == 1) && stick_up && enter_available){
			enter_available = false;
			final_entered = true;
			// entering audio
			enterPlayer.rewind();
			enterPlayer.play();
		}

		/* Display: Set camera ---------------- */
		camera.lookAt(0,height/2,width/2,0);

		/* Display: Background ---------------- */
		background(#000000);
		pushMatrix();
		rotateY(-HALF_PI);
		image(finalPageBg,0,0,width,height);
		popMatrix();

		/* Display: Score text ---------------- */
		pushMatrix();
		rotateY(-HALF_PI);
		fill(#efefef);
		textFont(righteous);
		textSize(64);
		text("Score",width/2-textWidth("Score")/2,320,0);
		popMatrix();

		/* Display: Score number ---------------- */
		pushMatrix();
		rotateY(-HALF_PI);
		fill(#efefef);
		textFont(righteous);
		textSize(100);
		text(str(score),width/2-textWidth(str(score))/2,480,0);
		popMatrix();

		/* Display: Play Again button ---------------- */
		String play_again_text = "Play Again";
		pushMatrix();
		rotateY(-HALF_PI);
		translate(width/2-160,640,0);
		// frame
		strokeWeight(4);
		stroke(#ffffff);
		if (select_focus == 0){
			fill(#ffffff);
		} else {
			noFill();
		}
		rect(0,0,320,64,80);
		textFont(righteous);
		textSize(32);
		if (select_focus == 0){
			fill(#52453a);
		} else {
			fill(#ffffff);
		}
		text(play_again_text,160-textWidth(play_again_text)/2,42,0);
		popMatrix();

		/* Display: Menu button ---------------- */
		String menu_text = "Menu";
		pushMatrix();
		rotateY(-HALF_PI);
		translate(1680,936,0);
		// frame
		strokeWeight(4);
		stroke(#ffffff);
		if (select_focus == 1){
			fill(#ffffff);
		} else {
			noFill();
		}
		rect(0,0,160,64,80);
		textFont(righteous);
		textSize(32);
		if (select_focus == 1){
			fill(#52453a);
		} else {
			fill(#ffffff);
		}
		text(menu_text,(160-textWidth(menu_text))/2,42,0);
		popMatrix();
		
		/* Page BGM ---------------- */
		finalPagePlayer.play();
		if (finalPagePlayer.position()>=finalPagePlayer.length()) finalPagePlayer.rewind();
		if (final_entered == true){
			finalPagePlayer.pause();
			finalPagePlayer.rewind();
		}
	}
	void reset(){
		select_available = true;
		stick_available = true;
		enter_available = false;
		select_focus = 0;
	}
}