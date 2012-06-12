
//"use strict"
$.Mason.prototype.resize = function() {
	this._getColumns();
	this._reLayout();
};
$.Mason.prototype._reLayout = function( callback ) {
	var freeCols = this.cols;
	if ( this.options.cornerStampSelector ) {
		var $cornerStamp = this.element.find( this.options.cornerStampSelector ),
		cornerStampX = $cornerStamp.offset().left -
		( this.element.offset().left + this.offset.x + parseInt($cornerStamp.css('marginLeft')) );
		freeCols = Math.floor( cornerStampX / this.columnWidth );
	}
	// reset columns
	var i = this.cols;
	this.colYs = [];
	while (i--) {
		this.colYs.push( this.offset.y );
	}
	for ( i = freeCols; i < this.cols; i++ ) {
		this.colYs[i] = this.offset.y + $cornerStamp.outerHeight(true);
	}
	// apply layout logic to all bricks
	this.layout( this.$bricks, callback );
};
/*****************Model Definitions*******************/
var Picture = Backbone.Model.extend({
	initialize : function(config){

	}
});
var User = Backbone.Model.extend({
	initialize : function(config){

	},
	isAuthed : function(){
		return this.fbId ? true : false;
	},
	setFBId : function(fbId){
		this.fbId = fbId;
	}
});
/*******************Collection Definitins********************/
var PictureCollection = Backbone.Collection.extend({
	initialize : function(config){

	}
});


/*******************Views Definitions*************************/
var Header = Backbone.View.extend({
	updateHeader : function(config){
		var that = this;
		this.el.fadeOut('fast',function(){
			that.el.html(that.loggedInTemplate(config.authResponse));
			that.el.fadeIn('slow');
		})
	},
	initialize : function(config){
		hub.bind('authed',this.updateHeader,this);
		this.el = $('header');
		this.loggedInTemplate = _.template(['<div class="navigation sticky">',
			'<h1 class="logo floatLeft"><asvn  href="#">Graboard</a></h1>',
			'<ul class="navigationLinks floatRight">',
			'<li class="recentPic">',
			'<a href="">PHOTOS </a>',
			'<div class="subNav displayNone subNavFirst">',
			'<ul>',
			'<li>',
			'<a href="">Most Popular Photos</a>',
			'</li>',
			'<li>',
			'<a href="">Most Recent Photos</a>',
			'</li>',
			'<li>',
			'<a href="">Photos Of The Day</a>',
			'</li>',
			'<li class="lastLi">',
			'<a href="">Photos Of The Week</a>',
			'</li>',
			'</ul>',
			'</div>',
			'</li>',
			'<li class="recentVideo">',
			'<a href="">VIDEOS </a>',
			'<div class="subNav displayNone subNavSecond">',
			'<ul>',
			'<li>',
			'<a href="">Most Popular Videos</a>',
			'</li>',
			'<li>',
			'<a href="">Most Recent Videos</a>',
			'</li>',
			'<li>',
			'<a href="">Videos Of The Day</a>',
			'</li>',
			'<li  class="lastLi">',
			'<a href="">Videos Of The Week</a>',
			'</li>',
			'</ul>',
			'</div>',
			'</li>',
			'<li class="allPhotos">',
			'<a href="">PHOTOS HUB </a>',
			'<div class="subNav displayNone subNavThird">',
			'<ul>',
			'<li>',
			'<a href="">Facebook</a>',
			'</li>',
			'<li>',
			'<a href="">Instagram</a>',
			'</li>',
			'<li>',
			'<a href="">Flicker</a>',
			'</li>',
			'<li>',
			'<a hr	ef="">Picasa</a>',
			'</li>',
			'<li  class="lastLi">',
			'<a href="">Google Plus</a>',
			'</li>',
			'</ul>',
			'</div>',
			'</li>',
			'<li class="ownerDetails">',
			'<div class="updatedBy box morphing-glowing floatLeft">',
			'<a href="javascript:void(0);">',
			'<span class="image-wrap " style="position:relative; display:inline-block; background:url(http://graph.facebook.com/<%=userID%>/picture) no-repeat center center; width: 35px; height: 35px;">',
			'</span>',
			'</a>',
			'<div class="subNav displayNone  subNavForth" style="right: -2px;top: 32px;z-index: -1;">',
			'<ul>',
			'<li>',
			'<a href="">Profile</a>',
			'</li>',
			'<li>',
			'<a href="">Invite</a>',
			'</li>',
			'<li>',
			'<a href="">Popular Photos</a>',
			'</li>',
			'<li>',
			'<a href="">Popular Videos</a>',
			'</li>',
			'<li>',
			'<a href="">Settings</a>',
			'</li>',
			'<li  class="lastLi">',
			'<a href="">Logout</a>',
			'</li>',
			'</ul>',
			'</div>',
			'</div>',
			'</li>',
			'</ul>',
			'</div>'].join(''));
		this.loggedOutTemplate = _.template([
			'<div class="navigation sticky">',
			'<h1 class="logo floatLeft"><a href="#">Graboard</a></h1>',
			'</div>'].join(''));
	},
	render : function(config){
		if(config.user && config.user.isAuthed()){
			$('header').html(this.loggedInTemplate(config.user));
		}else{
			$('header').html(this.loggedOutTemplate());
			$('.noAuthBox .login').click(function(){
				var loginPanel = new LoginPanel();
				loginPanel.render();
				FB.XFBML.parse();
			});

			$('.noAuthBox .invite').click(function(){
				var invitePanel = new InvitePanel();
				invitePanel.render();
				FB.XFBML.parse();
			});
		}
	}
});

var FilterPanel = Backbone.View.extend({
	initialize : function(config){
		this.template = _.template([
			'<div id="filterSale" class="bar">',
			'<div class="bar-section bar-section-view">',
			'<label>View:</label>',
			'<ul>',
			'<li>',
			'<div class="mainCategory category">',
			'<span class="mainCatList"></span><div>All</div>',
			'<em class="tringle"></em>',
			'<ul class="subCatLists displayNone">',
			'<li><a class="cat cat1" data-category="shoes"><span></span><div>Shoes</div></a></li>',
			'<li><a class="cat cat2" data-category="home"><span></span><div>Home & Decor</div></a></li>',
			'<li><a class="cat cat3" data-category="electronics"><span></span><div>Gadgets</div></a></li>',
			'<li><a class="cat cat4" data-category="mobile"><span></span><div>Accessories</div></a></li>',
			'<li><a class="cat cat5" data-category="books"><span></span><div>Books</div></a></li>',
			'<li><a class="cat cat6" data-category="jewellery"><span></span><div>Watches</div></a></li>',
			'<li><a class="cat cat7" data-category="apprel"><span></span><div>Apparel</div></a></li>',
			'<li><a class="cat cat7" data-category="kids"><span></span><div>Kids</div></a></li>',
			'</ul>',
			'</div>',
			'</li>',
			'<li>',
			'<div class="mainCategory price">',
			'<span class="mainCatList"></span>',
			'<div>Price</div>',
			'<em class="tringle"></em>',
			'<ul class="subCatLists priceList displayNone">',
			'<li><a class="cat1" data-category="1"><span></span><div>0-50</div></a></li>',
			'<li><a class="cat2" data-category="2"><span></span><div>50-250</div></a></li>',
			'<li><a class="cat3" data-category="3"><span></span><div>250-1000</div></a></li>',
			'<li><a class="cat4" data-category="4"><span></span><div>1000+</div></a></li>',
			'</ul>',
			'</div>',
			'</li>',
			'</ul>',
			'<div class="showhide" title="Hide"><em class="rightArrow"></em></div>',
			'</div>',
			'</div>'].join(''));
	},
	render : function (){
		$('.mainWrapper').append(this.template({}));
		this.el = $('#filterSale');
		this.addListeners();
	},
	addListeners : function(){
		var that = this;
		$('.showhide',this.el).click(function(){
			that.showHide();
		});
		$('.subCatLists a').click(function(e){
			that.filter(e,this);
		});
		$('.category')
	},
	showHide : function(){
		if(this.collapsed){
			this.show();
		}else{
			this.hide();
		}
		this.collapsed = !this.collapsed;
	},
	show : function(){
		var that = this;
		$('label,ul:not(.subCatLists)',this.el).show();
		$('.showhide',that.el).css({
			'float' : 'right'
		});
		this.el.animate({
			right : '0'
		},400,function(){
			$('.showhide em',that.el).removeClass('leftArrow').addClass('rightArrow');
		});
	},
	hide : function(){
		var that = this;
		this.el.animate({
			right : -740
		},400,function(){
			$('label,ul:not(.subCatLists)',this.el).hide();
			$('.showhide em',that.el).removeClass('rightArrow').addClass('leftArrow');
			$('.showhide',that.el).css({
				'float' : 'left'
			})
		});
	},
	filter : function(event,el){
		if($(el).hasClass('cat')){
			$('.category > div').html($('div',el).html());
			$('.category').removeClass().addClass($('span',el).parent().attr('class') + ' mainCategory category');
			$('.category div').after('<span class="remove"></remove>');
		}else{
			$('.price > div').html($('div',el).html());
			$('.price').removeClass().addClass($('span',el).parent().attr('class') + ' mainCategory price');
		}

		var items = [];
		for(var i = 0, len = Math.random()*20;i<len;i++){
			items.push($('#'+ Math.floor(Math.random()*20)).detach());
		}
		$('.mainWrapper').masonry('reload');

		for( i = 0, len = items.length;i<len;i++){
			$('.mainWrapper').append(items[i]);
		}
		$('.mainWrapper').masonry('reload');
	},
	removeFilter : function(filterId,scope){
		
	}
})

var InvitePanel = Backbone.View.extend({
	initialize : function(){

		this.template = _.template(["<div class='invitePanel lightBox'>",
			"<div class='close'></div>",
			"<h1>Sign up for an invite to join Graboard</h1>",
			"<span>or <em>login</em> to your account.</span>",
			"<input type='email' />",
			"<div class='left-shadow'></div><div class='right-shadow'></div></div>"].join(""));
		return this;
	},
	render : function(){
		var that = this;
		if($('.loginPanel').length){
			return;
		}
		$(document).keyup(function(e) {
			if (e.keyCode == 27) {
				$('.close',that.el).trigger('click');
			}
		});
		$('body').prepend(this.template({}));
		this.el = $('body .invitePanel');
		this.el.fadeIn('fast');
		$(function(){
			$("label").inFieldLabels();
		});
		this.addListeners();
		return this;
	},
	addListeners : function(){
		var that = this;
		$('.close',this.el).click(function(){
			that.el.fadeOut('fast',function(){
				that.el.remove();
			})
		});
	}
});
var LoginPanel = Backbone.View.extend({
	initialize : function(){
		hub.bind('authed',this.destroy,this);
		var that = this;

		this.template = _.template(['<div class="loginPanel lightBox border5">',
			"<div class='close'></div>",
			'<div class="socialButtons">',
			'<div class="btn fbBtn">',
			'<a class="fb loginButton border5">',
			'<div class="logoWrapper"><span class="logo"></span></div>',
			'<span>Login with Facebook</span>',
			'</a>',
			'</div>',
			'<div class="btn">',
			'<a class="tw loginButton border5">',
			'<div class="logoWrapper"><span class="logo"></span></div>',
			'<span>Login with Twitter</span>',
			'</a>',
			'</div>',
			'</div>',
			'<form class="authForm" method="POST" action="/login">',
			'<ul>',
			'<li>',
			'<input type="text" name="email" id="email">',
			'<label for="email">Email</label>',
			'<span class="fff"></span>',
			'</li>',
			'<li>',
			'<input type="password" name="password" id="password">',
			'<label for="password">Password</label>',
			'<span class="fff"></span>',
			'</li>',
			'<input type="hidden">',
			'</ul>',
			'<div class="buttons">',
			'<button class="loginBtn" type="submit">Login</button>',
			'<a href="/password/reset/">Forgot your password?</a>',
			'</div>',
			'</form>',
			"</div>"].join(""));
		return this;
	},
	render : function(){
		if($('.loginPanel').length){
			return;
		}
		$('body').prepend(this.template({
			fbLogin : true,
			gLogin : true,
			signUp : true
		}));
		this.el = $('body .loginPanel');
		this.el.fadeIn('fast');
		$(function(){ 
			$("label").inFieldLabels();
		});
		this.addListeners();
		return this;
	},
	addListeners : function(){
		var that = this;
		$(document).keyup(function(e) {
			if (e.keyCode == 27) {
				$('.loginPanel .close').trigger('click');
			}
		});
		$(".social_buttons .fb").click(function(){
			that.loginWithFB();
		});
		$(".social_buttons .tw").click(function(){
			that.loginWithTw();
		});
		$(".loginPanel .close").click(function(){
			that.el.fadeOut('fast',function(){
				that.el.remove();
			});
		});
	},
	loginWithFB : function(){
		FB.login(function(resp){
			if(resp.authResponse){
			//signed in, send this fb ID to server and login user associated with this fb account, if no user is associated with this fb ID ask him to request invite or get an invite from his friends
			}else{
		//cancelled sign in
		}
		});
	},
	loginWithTw : function(){
		console.log('connect with twitter for email');
	},
	destroy : function(){
		$('.loginPanel').remove();
	}
});

var TabPanel = Backbone.View.extend({

	});

var PictureWall = Backbone.View.extend({

	initialize : function(){
		hub.bind('authed',this.showCustomWall,this);
		hub.bind('guestInit',this.showGuestWall,this);

		this.items = [];
	},
	render : function(){

	},
	showCustomWall : function(){
		var that = this;
		$('.mainWrapper').activity();
		$.ajax({
			url : '/get-data.json',
			success : function(res){
				that.populateWall(res);
			},
			error : function(){
			//TODO show error message
			}
		});
	},
	populateWall : function(res){
		var that = this;
		setTimeout(function(){
			$('.mainWrapper').activity(false);
			app.getStore().reset(res.data);
			$('.mainWrapper').append("<div class='wishList'> Watched Items</div>");
			$('.wishList').droppable({
				drop : function(event,ui){
					var item = $(ui.draggable).detach();
					item.removeClass('tile');
					item.css({
						height: 64,
						width : 64,
						overflow : 'hidden'
					})
					$('.wishList').append(item);
					$('.mainWrapper').masonry('reload');
				}
			});
			for(var i=0,len=app.getStore().length;i<len;i++){
				var item = new PictureTile(app.getStore().at(i));
				item.render();
				$('.mainWrapper').append(item.el);
				that.items.push(item);
			}

			$('.mainWrapper').imagesLoaded(function(){

				$('.mainWrapper').masonry({
					itemSelector : '.tile',
					columnWidth : 270,
					cornerStampSelector: '.wishList'
				});
			});
		},20);
	},
	showGuestWall : function(){
		var that = this;
		$('.mainWrapper').activity();
		$.ajax({
			url : '/get-data.json',
			success : function(res){
				that.populateWall(res);
			},
			error : function(){
			//TODO show error message
			}
		});
	}
});

var PictureTile = Backbone.View.extend({
	tagName : 'div',
	className : 'tile',

	initialize : function(config){
		this.template = _.template([
			'<div itemtype="javascript:void(0)" itemscope="" class="item photo">',
			'<div class="modal-media wrapper cboxElement  view second-effect">',
			'<a class="imgContent" href="#">',
			'<img width="240" src="<%=imageUrl%>" alt="">',
			'</a>',

			'<div class="mask">',
			'<div class="itemDisc">',
			'<span class="itemName">Arrow New York</span>',
			'<span class="itemNameDesc">Men Check Navy Blue Shirt</span>',
			'<div class="priceDetails">',
			'<div class="floatLeft">',
			'<span class="discountedPrice red">Rs. 810 <span class="strike gray originalPrice">899</span></span>',
			'<div class="perOff red fontBold">(10% OFF)</div>',
			'</div>',
			'<div class="floatRight">',
			'<a class="grabIt " target="_self" href="#"><span class="left"> Grab It! </span></a>',
			'</div>',
			'</div>',
			'</div>',
			'<div class="socialToolbar socialLinks forLiveFeeds showtoolbar" style="">',
			'<span class="floatLeft" style="margin-top: 8px;margin-left: 5px;background: green">',
			'</span>',
			'<span class="floatLeft flike" style="margin-top: 8px;margin-left: 5px;background: green"></span>',
			'</div>',
			'</div>',
			'</div>',
			'<div class="modal-media wrapper cboxElement">',
			'<div class="typeInfo clear">',
			'<div class="floatLeft">',
			'<span class="updatedBy box morphing-glowing floatLeft"  style="width: 100%;">',
			'<a href="javascript:void(0);">',
			'<span class="image-wrap " style="position:relative; display:inline-block; background:url(<%=source.logo%>) no-repeat center center; background-size: 47px 55px;width: 40px; height: 40px;">',
			'<img width="40" height="40" src="<%=source.logo%>" style="opacity: 0; ">',
			'</span>',
			'</a>',
			'<a href="javascript:void(0);" class="profilePic floatRight" style="margin: 10px 0 0 5px;"><span class="font11" style="color:#999">by</span> <span class="font12"><%=source.name%></span></a>',
			'</span>',
			'</div>',
			'<div class="floatRight font12" style="margin-top: 14px;">',
			'<span class="howMayLicks color3 floatRight">',
			'<span class="heartIconGray floatLeft" style="margin-right: 3px"></span>',
			'<span class="favCount floatRight">12</span>',
			'</span>',
			'</div>',
			'<div class="clear"></div>',
			'<div class="itemDisc onMainSaleWall" style="padding: 0 5px 10px;">',
			'<span class="itemName" style="display: block">Arrow New York</span>',
			'<span class="itemNameDesc"  style="display: block">Men Check Navy Blue Shirt</span>',
			'<div class="priceDetails" style="height: 25px;padding-top: 4px;">',
			'<div class="floatLeft">',
			'<div class="perOff red fontBold">(10% OFF) Rs. 810 </div>',
			'</div>',
			'<div class="floatRight displayNone grabButton">',
			'<a class="grabIt " style="height: 10px;line-height: 8px;"target="_self" href="#"><span class="left"> Grab It! </span></a>',
			'</div>',
			'</div>',
			'</div>',
			'</div>',
			'</div>',
			'</div>'
			].join(""));

		this.model = config;
		return this;
	},
	render : function(){
		$(this.el).html(this.template(this.model.toJSON()));
		this.addHandlers();
		$(this.el).draggable({
			stop : function(){
				$('.mainWrapper').masonry('reload');
				$(this).removeClass('noAnimation');
			},
			start : function(){
				$(this).addClass('noAnimation');
			}
		});
		return this;
	},
	addHandlers : function(){
		var that = this;
		$(".grabIt ",this.el).click(function(){
			that.grabIt();
		});
	},
	grabIt : function(){
		var item = $(this.el).detach();
		item.removeClass('tile');
		item.css({
			height: 64,
			width : 64,
			overflow : 'hidden',
			top : 0,
			left : 0
		})
		$('.wishList').append(item);
		$('.mainWrapper').masonry('reload');
	},
	addToWishList : function(){

	}
});
$(function(){
	hub = {};
	_.extend(hub, Backbone.Events);
	app = (function(){
		window.fbAsyncInit = function() {
			FB.init({
				appId      : '292741004148766',
				status     : true,
				cookie     : true,
				xfbml      : true,
				oauth      : true
			});
		};
		(function(d){
			var js, id = 'facebook-jssdk';
			if (d.getElementById(id)) {
				return;
			}
			js = d.createElement('script');
			js.id = id;
			js.async = true;
			js.src = "//connect.facebook.net/en_US/all.js";
			js.onload = function(){

				var checkInitId = setInterval(function(){
					if(FB._initialized){
						clearInterval(checkInitId);
						//check whether logged in or not
						FB.getLoginStatus(function(response) {
							if(response.status === "connected"){
								hub.trigger("authed",response);
							}else{
								FB.Event.subscribe('auth.statusChange', function(response) {
									if(response.status === "connected"){
										hub.trigger("authed",response);
									}
								});
								hub.trigger("guestInit",response);
							}
						});
					}

				},100);

			};
			d.getElementsByTagName('head')[0].appendChild(js);
		}(document));

		var user,loginPanel,header,pictureWall,store;
		header = new Header({
			user : user
		});
		header.render({
			user : user
		});
		pictureWall = new PictureWall({
			user : user
		});
		filterPanel = new FilterPanel({
			user : user
		});
		filterPanel.render();
		store = new PictureCollection();
		return {
			getUser : function(){
				return user;
			},
			getStore : function(){
				return store;
			},
			showUserContent : function(){

			},
			showGuestContent : function(){

			}
		};
	})();

	hub.bind('guestInit',app.showGuestContent,app);
})

/*
 ,{
			'itemId' : '13',
			'imageUrl' : 'http://media-cache3.pinterest.com/upload/138204282285373226_bBCIyvJc_b.jpg'
		},{
			'itemId' : '14',
			'imageUrl' : 'http://media-cache2.pinterest.com/upload/130393351681631158_yHNNc324_b.jpg'
		},{
			'itemId' : '15',
			'imageUrl' : 'http://media-cache3.pinterest.com/upload/138204282285373226_bBCIyvJc_b.jpg'
		},{
			'itemId' : '16',
			'imageUrl' : 'http://media-cache2.pinterest.com/upload/130393351681631158_yHNNc324_b.jpg'
		},{
			'itemId' : '17',
			'imageUrl' : 'http://media-cache1.pinterest.com/upload/194006696418196817_Pl6q6rwf_b.jpg'
		},{
			'itemId' : '18',
			'imageUrl' : 'http://media-cache3.pinterest.com/upload/138204282285373226_bBCIyvJc_b.jpg'
		},{
			'itemId' : '19',
			'imageUrl' : 'http://media-cache5.pinterest.com/upload/139611657168867043_LJVIuqfY_b.jpg'
		},{
			'itemId' : '20',
			'imageUrl' : 'http://media-cache8.pinterest.com/upload/159314905538663633_OXKg3W1o_b.jpg'
		}
 **/


