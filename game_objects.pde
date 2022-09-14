class Airplane{
	PShape airplane;
	PImage airplaneSkin;
	
	// Camera
	float cam_Pos_z = width/2;
	float cam_Pos_y = height/2;
	
	// For airplane
	// ready mode
	float select_pos_y = 840;
	float select_pos_z = 0;
	float entering_pos_y = 540;
	float entering_pos_z = 0;
	float entering_pos_x = -1000;
	boolean flyIn = false;
	// gaming mode
	float pos_z = width/2;
	float pos_y = height/2;
	float theta = 0;
	int lean_mode = 0;
	float turnSpeed = 0.16;

	// Windy shake
	int shake_speed;
	int shake_direction;
	int shake_movement;
	int shake_count;
	boolean shake_random = true;
	
	Airplane(String obj, String skin){
		airplane = loadShape(obj); 
		airplaneSkin = loadImage(skin); 
		airplane.setTexture(airplaneSkin);
		airplane.scale(20);
	}

	void reset(){
		cam_Pos_z = width/2;
		cam_Pos_y = height/2;
		// ready mode
		select_pos_y = 840;
		select_pos_z = 0;
		entering_pos_y = 540;
		entering_pos_z = 0;
		entering_pos_x = -1000;
		flyIn = false;
		// gaming mode
		pos_z = width/2;
		pos_y = height/2;
		theta = 0;
		lean_mode = 0;
		turnSpeed = 0.16;	
	}

	void selectDisplay(int select_focus, boolean entering){
		if (entering){
			// Selected: flying up animation
			pushMatrix();
			if (flyIn == false){
				if (select_focus == 0){
					select_pos_z = 580;
					entering_pos_z = 580;
				} else if (select_focus == 1) {
					select_pos_z = 960;
					entering_pos_z = 960;
				} else if (select_focus == 2) {
					select_pos_z = 1340;
					entering_pos_z = 1340;
				}
				select_pos_y-=20;
				if (select_pos_y == -500){
					select_pos_y = -500;
					flyIn = true;
				}
			}
			translate(-40,select_pos_y,select_pos_z);
			rotateZ(HALF_PI);
			scale(0.4);
			shape(airplane,0,0);
			popMatrix();
		} else {
			// Not selected: airplane position control
			pushMatrix();
			if (select_focus == 0){
				translate(-40,840,580);
			} else if (select_focus == 1){
				translate(-40,840,960);
			} else if (select_focus == 2){
				translate(-40,840,1340);
			} else if (select_focus == 3){
				translate(-40,2000,2000); // out of window
			}
			rotateZ(HALF_PI);
			scale(0.4);
			shape(airplane,0,0);
			popMatrix();
		}
		// flying in animation
		if (flyIn == true){
			pushMatrix();
			entering_pos_x+=20;
			if (entering_pos_x >= 120) level_selected = true;
			translate(entering_pos_x,entering_pos_y,entering_pos_z);
			rotateZ(PI);
			shape(airplane,0,0);
			popMatrix();
		}
	}

	void flyingControl(float control_z, float control_y){
		// camera position changes when control
		float cam_dz = control_z - cam_Pos_z;
		float cam_dy = control_y - cam_Pos_y - 100;
		cam_Pos_z = cam_Pos_z + cam_dz / 18;
		cam_Pos_y = cam_Pos_y + cam_dy / 18;
		camera.lookAt(0,cam_Pos_y,cam_Pos_z,0);

		// airplane translate
		float dz = control_z - pos_z;
		float dy = control_y - pos_y;
		pos_z += dz / 10;
		pos_y += dy / 10;

		// airplane rotate
		if (lean_mode == 0){ // middle
			if (dz >= 35){
				lean_mode = 1;
			} else if (dz <= -35){
				lean_mode = 2;
			} else {
				// turn back
				turnSpeed = 0.08;
				if (theta > 0) { // right back
					theta -= turnSpeed;
					airplane.rotateX(-turnSpeed);
				} else if (theta < 0) { // left back
					theta += turnSpeed;
					airplane.rotateX(turnSpeed);
				}
			}
		} else if (lean_mode == 1) { // right
			if (theta <= 0.4){
				theta += turnSpeed;
				airplane.rotateX(turnSpeed);
			} else {
				lean_mode = 0;
			}
		} else if (lean_mode == 2) { // left
			if (theta >= -0.4){
				theta -= turnSpeed;
				airplane.rotateX(-turnSpeed);
			} else {
				lean_mode = 0;
			}
		}
		
		// airplane display
		pushMatrix();
		translate(0,pos_y,pos_z);
		rotateZ(PI);
		shape(airplane, 0, 0);
		popMatrix();

		// Set audio
		// if (airplanePlayer.isPlaying() == false){
		// 	airplanePlayer.rewind();
		// 	airplanePlayer.play();
		// }
	}

	void windyShake(String shake_mode){
		if(!stick_lock){
			// Get random
			if (shake_random){
				shake_random = false;
				shake_count = 0;
				shake_direction = int(random(0,7));
				if (shake_mode == "slight"){
					shake_speed = 3;
					shake_movement = int(random(20,50));
				} else if (shake_mode == "strong"){
					shake_speed = 4;
					shake_movement = int(random(40,100));
				} else if (shake_mode == "static") {
					shake_speed = 0;
					shake_movement = 0;
				}
			}

			// movement count
			if (shake_count <= shake_movement 
				&& (shake_mode == "slight"||shake_mode == "strong")) shake_count += shake_speed;
			else shake_random = true;

			// movement
			switch (shake_direction) {
				case 0: // N
					control_y-=shake_speed;
					break;	
				case 1: // NE
					control_z+=shake_speed;
					control_y-=shake_speed;
					break;	
				case 2: // E
					control_z+=shake_speed;
					break;	
				case 3: // SE
					control_z+=shake_speed;
					control_y+=shake_speed;
					break;	
				case 4: // S
					control_y+=shake_speed;
					break;	
				case 5: // SW
					control_z-=shake_speed;
					control_y+=shake_speed;
					break;	
				case 6: // W
					control_z-=shake_speed;
					break;	
				case 7: // NW
					control_z-=shake_speed;
					control_y-=shake_speed;
					break;	
			}
		}
	}
}

class Ring{
	PShape ring;
	int start = 8400; // x axis
	float pos_z = width/2;
	float pos_y = height/2;

 	Ring(String obj){
		ring = loadShape(obj);
		ring.scale(8);
		ring.rotateX(3*HALF_PI);
		ring.setFill(#ffc86c);
 	}

 	void reset(){
 		start = 8400;
 		pos_z = width/2;
		pos_y = height/2;
 	}

 	void colored(int c){
		ring.setFill(c);
 	}

	void generator(){
		// Display
		start -= flying_speed;
		pushMatrix();
		rotateY(-HALF_PI);
		translate(0,0,-start); // new z axis
		shape(ring, pos_z, pos_y);
		popMatrix();
		if (start <= -200){
			start = 16800;
			pos_z = random(400, 1520);
			pos_y = random(200, 880);
		}

		// Effect region
		// pushMatrix();
		// rotateY(-HALF_PI);
		// translate(pos_z-280, pos_y-240, -start);
		// noFill();
		// stroke(#000000);
		// rect(0, 0, 540, 480);
		// popMatrix();
 	}

 	int flyInExam(){
		if (start <= 0){
			if (airplane.pos_z <= (pos_z + 280) 
				&& airplane.pos_z >= (pos_z - 280) 
				&& airplane.pos_y <= (pos_y + 240)
				&& airplane.pos_y >= (pos_y - 240)){
				return 1;
			}
			else return 2;
		}
		return 3;
	}
}

class Coin{
	PShape coin;
	float pos_x, pos_y, pos_z, start;
	int coin_type = 0;
	int coin_color;

	Coin(String obj){
		coin = loadShape(obj);
		coin.scale(3.1);
		coin.translate(24,24,0);
	}

	void reset(){
		start = random(-16800,-8400);
	}

	void display(int type){
		// type
		if (type == 1) {
			coin_type = 1;
			coin_color = #ff6e86;
		} else if (type == 2){
			coin_type = 2;
			coin_color = #6ea6ff;
		} else if (type == 3){
			coin_type = 3;
			coin_color = #ffd52b;
		}

		// moving
		if (start >= 200) {
			pos_z = random(400, 1520);
			pos_y = random(200, 880);
			start = random(-16800,-8400);
		}
		else start += flying_speed;
		
		pushMatrix();
		rotateY(-HALF_PI);
		
		// coin display
		translate(0,0,start);
		coin.setFill(coin_color);
		shape(coin,pos_z,pos_y);

		// Effect region line
		// pushMatrix();
		// noFill();
		// stroke(#ff0000);
		// rect(pos_z-120,pos_y-72,288,192);
		// popMatrix();

		popMatrix();
	}

	int coinEatenExam(){
		if (start >= 0){
			if (airplane.pos_z <= (pos_z + 168)
				&& airplane.pos_z >= (pos_z - 120)
				&& airplane.pos_y <= (pos_y + 120)
				&& airplane.pos_y >= (pos_y - 72)){
				return 1;
			}
			else return 2;
		}
		return 3;
	}
}

class Cloud{
	PShape cloud;
	float pos_x, pos_y, pos_z;
	float veritcal_lower_bound = height/3;

 	Cloud(String obj){
		cloud = loadShape(obj);
		cloud.rotateX(3*HALF_PI);
		cloud.setFill(#efefef);
		cloud.scale(random(8,25));
		pos_x = random(-6*width,7*width);
		pos_y = random(-4*height,veritcal_lower_bound);
		pos_z = -7800;
 	}

	void display(int c, float vlb){
		veritcal_lower_bound = vlb;
		if (pos_x <= -6*width) pos_x = 7*width; // reset cloud position
		else pos_x -= 8;
		cloud.setFill(c);
		pushMatrix();
		rotateY(-HALF_PI);
		translate(0,0,pos_z);
		shape(cloud,pos_x,pos_y);
		popMatrix();
 	}
}

class Canyon{
	PShape canyon;

	Canyon(String obj){
		canyon = loadShape(obj);
		canyon.scale(25);
		canyon.rotateY(-3*HALF_PI);
		canyon.setFill(#9c8368);
	}

	void display(){
		pushMatrix();
		rotateY(-HALF_PI);
		translate(width/2,0,0);
		shape(canyon,0,0);
		popMatrix();
	}
}

class Rain{
	float length;
	float pos_z;
	float pos_y;
	float pos_x;

	Rain(){
		length = random(10,50);
		pos_z = random(-0.5*width,1.5*width);
		pos_y = random(-height,2*height);
		pos_x = random(-2*height,400); // depth
	}

	void display(){
		pushMatrix();
		rotateY(-HALF_PI);
		fill(#3c4d63);
		noStroke();
		// drop down
		if (pos_y >= 2*height) pos_y = -height;
		else pos_y += 30;
		// windy
		if (pos_z <= -0.5*width) pos_z = 1.5*width;
		else pos_z -= 10;
		rotateZ(-tan(3));
		translate(0,0,pos_x);
		rect(pos_z,pos_y,1,length);
		popMatrix();
	}
}

class Sea{
	PShape sea;

	Sea(String obj){
		sea = loadShape(obj);
		sea.scale(40);
		sea.rotateY(-3*HALF_PI);
		sea.setFill(#07101f);
	}

	void display(){
		pushMatrix();
		rotateY(-HALF_PI);
		translate(width/2,0,0);
		shape(sea,0,0);
		popMatrix();
	}
}

class Scene{
	float g_pos = 0; // front grass position
	float c_pos = 0; // canyon position
	float s_pos = 0; // sea position
	int lightning = 0;
	int lightning_sky = #2E3138;
	float lightning_pos = 0;
	Scene(){}

	void reset(){
		g_pos = 0; // front grass position
		c_pos = 0; // canyon position
		s_pos = 0; // sea position
		lightning = 0;
		lightning_sky = #2E3138;
		lightning_pos = 0;
	}

	void display(int theme_num){
		// level 1 scene
		if (theme_num == 1){
			// Set audio
			if (windyPlayer1.isPlaying() == false){
				windyPlayer1.rewind();
				windyPlayer1.play();
			}
			// Set background
			background(#7dd3ff);
			// Set lights
			directionalLight(100,80,120,1,1,0);
			ambientLight(220,220,220);
			// Clouds
			for (int i = 0; i < clouds.length; i++){
				if(i%2 == 0) clouds[i].display(#efefef,-height/2);
				else clouds[i].display(#ffc4e8,height/2);
			}
			// Set ground
			grassDisplay(#AEDF72,#87BC62,#FCBE5B,flying_speed);
		// Level 2 scene
		} else if (theme_num == 2) {
			// Set audio
			if (windyPlayer2.isPlaying() == false){
				windyPlayer2.rewind();
				windyPlayer2.play();
			}
			// Set background
			background(#a9ccde);
			// Set lights
			directionalLight(150,80,100,1,1,0);
			ambientLight(235,235,235);
			// Clouds
			for (int i = 0; i < clouds.length; i++){
				if(i%2 == 0) clouds[i].display(#efefef,-height/2);
				else clouds[i].display(#ffefd6,height/2);
			}
			// Canyon
			c_pos += flying_speed;
			for (int i = 0; i < canyons.length; i++){
				if (c_pos >= 9250) c_pos = 0;
				pushMatrix();
				translate(i*9250-c_pos,0,0);
				canyons[i].display();
				popMatrix();
			}
		// Level 3 scene
		} else if (theme_num == 3) {
			// Set audio
			if (rainPlayer.isPlaying() == false){
				rainPlayer.rewind();
				rainPlayer.play();
			}
			// thunder animation (control background)
			lightningAni();
			// Set lights
			directionalLight(150,80,100,1,1,0);
			ambientLight(150,200,200);
			// Clouds
			for (int i = 0; i < clouds.length; i++){
				clouds[i].display(#393e45,-height);
			}
			// Rain
			for (int i = 0; i < rains.length; i++){
				rains[i].display();
			}
			// Sea
			s_pos += flying_speed;
			for (int i = 0; i < seas.length; i++){
				if (s_pos >= 10000) s_pos = 0;
				pushMatrix();
				translate(i*10000-s_pos,height,0);
				seas[i].display();
				popMatrix();
			}
		}
	}

	void grassDisplay(int fc_1, int fc_2, int bc, float speed){
		rotateY(-HALF_PI);
		
		// front ground
		pushMatrix();
		translate(-width,height+699, 600);
		rotateX(-HALF_PI);
		noStroke();
		g_pos += speed;
		for (int i = 0; i < 21; i++){
			if(i % 2 == 0) fill(fc_1);
			else fill(fc_2);
			if (g_pos >= height) g_pos = 0;
			rect(0, i*height/2-g_pos,3*width, height/2);
		}
		popMatrix();

		// back ground
		pushMatrix();
		translate(-5*width, height+700, 600);
		rotateX(-HALF_PI);
		fill(bc);
		noStroke();
		rect(0, 0, 12*width, 10*height);
		popMatrix();
		
		rotateY(HALF_PI);
	}

	void lightningAni(){
		background(lightning_sky);
		pushMatrix();
		rotateY(-HALF_PI);
		translate(lightning_pos,-5400,-8400);
		scale(8);
		// lightning animaiton
		if (frameCount%420 <= 105){ // interval: 6s; duration: 2s;
			if (lightning >= 255) lightning-=80; // for flash
			else lightning+=20;
			lightning_sky = #454a54;
		} else {
			lightning = 0;
			lightning_sky = #2E3138;
		}
		// random lightning position
		if (frameCount%420 == 0) {
			lightning_pos = random(-10000,5000);
		}
		tint(255,255,255,lightning);
		image(lightningImg,0,0,912,1000);
		noTint();
		popMatrix();
		// thunder sound effect
		if (frameCount%420 == 0) {
			if (thunderPlayer2.isPlaying()){
				thunderPlayer1.play();
				thunderPlayer1.rewind();
			}
			else if (thunderPlayer1.isPlaying()){
				thunderPlayer2.play();
				thunderPlayer2.rewind();
			}
			else {
				thunderPlayer1.play();
				thunderPlayer1.rewind();
			}
		}
	}
}

class StatusPanel{
	// panel infomation
	int score = 0;
	int life = max_life;
	float panel_OringnalX;
	float panel_OringnalY;
	int panel_last_time = second();
	int panel_time_counter = 0;
	boolean panel_time_trigger = true;
	StatusPanel(){}

	void display(){
		// Rotate all Panel
		rotateY(-HALF_PI);
		
		// Cam follow control
		panel_OringnalX = airplane.cam_Pos_z - width/2 + 50;
		panel_OringnalY = airplane.cam_Pos_y - height/2 + 50;
		
		// Panel frame
		// pushMatrix();
		// translate(panel_OringnalX,panel_OringnalY,0);
		// noFill();
		// stroke(#52453a);
		// strokeWeight(1);
		// rect(0,0,width-100,height-100);
		// popMatrix();
		
		// Score display
		scoreDisplay(0,0,256,56,score);

		// Life display
		lifeDisplay(64,80,40,life);

		// Time display
		// timerDisplay(width/2-50,0,48);

		rotateY(HALF_PI);
	}

	void reset(){
		score = 0;
		life = max_life;
		panel_last_time = second();
		panel_time_counter = 0;
		panel_time_trigger = true;
	}

	void scoreDisplay(float x,float y,float w,float h, int value){
		x += panel_OringnalX;
		y += panel_OringnalY;
		pushMatrix();
		image(underLayer_r,x+h/2,y,w,h); // rect
		image(underLayer_scr,x+w+h/2,y,h/2,h); // semi circle right
		// image(underLayer_scl,x,y,h/2,h); // semi circle left
		// image(starIcon,x-h*0.5,y-h*0.5,h*1.8,h*1.8);
		image(trophyIcon,x-h*0.25,y-h*0.25,h*1.5,h*1.5);
		textDisplay(w+h/2,0,str(score),h*0.75,#efefef,"right");
		popMatrix();
	}

	void lifeDisplay(float x,float y,float w, int life){
		x += panel_OringnalX;
		y += panel_OringnalY;
		pushMatrix();
		for (int i=0;i<max_life;i++) image(heart_e,x+i*(w+10),y,w,w*0.9);
		for (int i=0;i<life;i++) image(heart_f,x+i*(w+10),y,w,w*0.9);
		popMatrix();
	}

	void timerDisplay(float x,float y, float fs){
		// time interval trigger
		if (panel_time_trigger){
			panel_last_time = second();
			panel_time_counter++;
			panel_time_trigger = false;
		} else if (second() - panel_last_time >= 1) panel_time_trigger = true;
		// timer display
		textDisplay(x,y,nf(panel_time_counter/60,2)+":"+nf(panel_time_counter%60,2),fs,#efefef,"center");
	}
	
	void textDisplay(
		float x, float y, String text,
		float font_size, int font_color, String align){
		x += panel_OringnalX;
		y += panel_OringnalY;
		pushMatrix();
		fill(font_color);
		textFont(righteous);
		textSize(font_size);
		if (align == "center") text(text,x-textWidth(text)/2,y+font_size);
		else if (align == "left") text(text,x,y+font_size);
		else if (align == "right") text(text,x-textWidth(text),y+font_size);
		popMatrix();
	}
}