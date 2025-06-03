 /*------------------------------------------------------------------------------
Copyright (c) 2011 Antoine Santo Aka NoNameNo

This File is part of the CODEF project.

More info : http://codef.santo.fr
Demo gallery http://www.wab.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
------------------------------------------------------------------------------*/
/*
This file is done by TotorMan... ;)
and then tweaked by Mellow Man (again)
to make an Amiga decrunch for Workbench 3.1 versions
*/

function AmigaDecrunch(DType, MaxBarHeight, StartDecrunchAt, DecrunchMaxVBL) {

	var whichcolor=0;
	var extrah=0;

function get_color() {
	    var choices = ['#000088','#005544','#0033FF','#0022EE','#002200','#00DD44','#009966','#0099DD','#00BBCC','#00FF00'];
	    var color = choices[Math.round(Math.random() * 10)];
            return color;
        }

function get_color2() {
	    var choices = ['#000000','#FFFFFF','#000000','#FFFFFF','#000000','#FFFFFF','#000000','#FFFFFF','#000000','#FFFFFF'];
	    var color = choices[Math.round(Math.random() * 10)];
            return color;
        }

    // Amiga shell window
    this.amigashell = new Image() ;
    // base64 encoded PNG
    this.amigashell.src="data:image/png;base64,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";
    // Mouse, Cursor, black parts of shell window
    this.amigashelltop = new Image() ;
    // base64 encoded PNG
    this.amigashelltop.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAtAAAAI4CAMAAAB0ni5BAAAAB3RJTUUH4AEQEhQUnD+7OwAAAAlwSFlzAAAOwwAADsMBx2+oZAAAAARnQU1BAACxjwv8YQUAAAAPUExURaqqqmaIuwAAAO5ERO7uzENrmmUAAAABdFJOUwBA5thmAAACJ0lEQVR42u3aQQqDQBQFQaPe/8xBBk32GoY0VSd4i158mFkWAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAuGzbvs/eAI8RNCnreiQtaiIETcyRtKjJEDQpI2hREyFoYj5Ji5oAQZPyHfRh9h64RdDEnEk7N0gQNCkj6PEMPnsL3CZoYo6Yz69Ks7fAbYImZQQtaSIETdSZNiQIGgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgP7wus5fAAwRNiqBJETQpgiZF0KQImhRBkyJoUgRNiqBJETQpgiZF0KQImhRBkyJoUgQNAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8GNvQu8DYUPdh4cAAAAASUVORK5CYII=";

    // Total time for the decrunch effect
    this.DecrunchMaxVBL=DecrunchMaxVBL;
    // Current decrunch vbl counter
    this.DecrunchVBLs=0;
    // Before that point, only shell window, after that point, decrunch visible
    this.StartDecrunchAt=StartDecrunchAt;

    // Decrunch types
    this.NoAmigaShell=0 ;    // bars are full screen
    this.AmigaShellBlink=1 ; // bars are on the Amiga Shell white lines
    this.AmigaShellOver=2 ;  // bars are behind the Amiga Shell white lines
    this.AmigaShellMoving1=3 ; // bars behind the Amiga Shell & it 'judders'
    this.AmigaShellMoving2=4 ; // no bars & the Amiga Shell 'judders'

    // user choice decrunch type
    this.DType = DType ;
    this.palette = new Array() ;

    // base size of decrunch bar
    this.MaxBarHeight = MaxBarHeight ;

    // working canvas
    this.mycanvas_temp = new canvas(720,512)

    // = 1 when all is done
    this.finished = 0 ;

    this.doDecrunch=function(dest) {

        // working canvas sizes
        var W = this.mycanvas_temp.contex.canvas.width ;
        var H = this.mycanvas_temp.contex.canvas.height ;
        // images sizes
        var w1 = this.amigashell.width;
        var h1 = this.amigashell.height;
        var w2 = this.amigashelltop.width;
        var h2 = this.amigashelltop.height;
        // Before decrunch we only draw the Amiga shell window
        if (this.DecrunchVBLs<this.StartDecrunchAt) {
            this.mycanvas_temp.contex.drawImage(this.amigashell,0,-33,w1,h1) ;
            this.mycanvas_temp.contex.drawImage(this.amigashelltop,0,-33,w2,h2);
        } else {
            // We will parse y
            var y=0 ;
            // While not parsed all height of working canvas
            while (y<=H) {
                // calculate color bar height
		var barh = (1+Math.random())*this.MaxBarHeight ;
		extrah=Math.floor((Math.random()*5)+1);
                // draws the bar
                var mycolor ;
                if ( ((this.DType==this.AmigaShellOverPalette) || (this.DType==this.NoAmigaShellPalette)) && (this.palette.length >0) ) {
                    mycolor = get_color();
                } else {
     		mycolor = get_color();
		whichcolor=Math.floor((Math.random()*6)+1);
		if (this.DType==this.AmigaShellBlink) mycolor = get_color2();
                }
		 if (this.DType==this.AmigaShellMoving2) mycolor='#AAAAAA';
		 if (this.DType==this.AmigaShellMoving1) mycolor=get_color();
                this.mycanvas_temp.contex.fillStyle = mycolor ;
                this.mycanvas_temp.contex.fillRect(0,y,W,barh+extrah) ;
                   // next bar
                y += barh;
            }

            // if Amiga shell window is the only thing that must blink
            if (this.DType==this.AmigaShellBlink) {
                // set destination-in canvas mode
                this.mycanvas_temp.contex.globalCompositeOperation='destination-in';
                // draw the Amiga shell window
                this.mycanvas_temp.contex.drawImage(this.amigashell,0,-33,w1,h1) ;
                // back to normal mode
                this.mycanvas_temp.contex.globalCompositeOperation='source-over';
                // draw front things (mouse, cursor, ...)
                this.mycanvas_temp.contex.drawImage(this.amigashelltop,0,-33,w2,h2);
            }
            // if bars must appear behind the amiga shell window
            if ( (this.DType==this.AmigaShellOver) || (this.DType==this.AmigaShellOverPalette) ) {
                // draw the images over the bars
                this.mycanvas_temp.contex.drawImage(this.amigashell,0,-33,w1,h1) ;
                this.mycanvas_temp.contex.drawImage(this.amigashelltop,0,-33,w2,h2);
            }
	    if ( ( this.DType==this.AmigaShellMoving1) || ( this.DType==this.AmigaShellMoving2) ) {
		for (var yg=0; yg<h2; yg+=barh){
			var move = Math.round(Math.random() * 30);
			var barh=this.MaxBarHeight;
			this.mycanvas_temp.contex.drawImage(this.amigashell,0,yg,w1,barh,-15+move,yg-33,w1,barh);
			this.mycanvas_temp.contex.drawImage(this.amigashelltop,0,yg,w2,barh,-15+move,yg-33,w2,barh);
			}
		}
        }
        // put destination canvas into no AA mode
        dest.contex.ImageSmoothingEnabled=false;
        dest.contex.mozImageSmoothingEnabled=false;
        dest.contex.oImageSmoothingEnabled=false;

        // fill with the WB3.1 background colour
        dest.fill('#AAAAAA');

        // calculate the destination scale
        var scx = dest.contex.canvas.width/W  ;
        var scy = dest.contex.canvas.height/H  ;

        // draw that decrunch
        this.mycanvas_temp.draw(dest,0,0,1,0,scx,scy);

        // next frame please
        this.DecrunchVBLs++;

        // are we finished ?
        if (this.DecrunchVBLs >= this.DecrunchMaxVBL) { this.finished = 1 ; }
    }

    return this ;
}

