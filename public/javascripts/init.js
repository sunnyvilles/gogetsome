//"use strict"

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
			'<h1 class="logo floatLeft"><a href="#">XXX</a></h1>',
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
			'<h1 class="logo floatLeft"><a href="#">XXX</a></h1>',
		'</div>'].join(''));
	},
	render : function(config){
		if(config.user && config.user.isAuthed()){
			$('header').html(this.loggedInTemplate(config.user));
		}else{
			$('header').html(this.loggedOutTemplate());
		}
	}
});
var LoginPanel = Backbone.View.extend({
	initialize : function(){
		hub.bind('authed',this.destroy,this);
		var that = this;
		this.template = _.template(["<div class='loginPanel'>",
			"<div class='fb-login-button'>Login with Facebook</div>",
			"</div>"].join(""));
		return this;
	},
	render : function(){
		$('.mainWrapper').html(this.template({
			fbLogin : true,
			gLogin : true,
			signUp : true
		}));
		this.el = $('.mainWrapper .loginPanel');
		return this;
	},
	destroy : function(){
		$('.mainWrapper .loginPanel').remove();
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
				for(var i=0,len=app.getStore().length;i<len;i++){
					var item = new PictureTile(app.getStore().at(i));
					item.render();
					$('.mainWrapper').append(item.el);
					that.items.push(item);
				}
				$('.mainWrapper').imagesLoaded(function(){
					$('.mainWrapper').masonry({
						itemSelector : '.tile',
						columnWidth : 270
					});
				});
			},2000);
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
                  '<span class="image-wrap " style="position:relative; display:inline-block; width:40px;background:url(images/logo-myntra.png) no-repeat center center; background-size:60px 40px; height: 40px;">',
                    '<img height="40" width="40" src="images/logo-myntra.png" style="opacity: 0; ">',
                  '</span>',
                '</a>',
                '<a href="javascript:void(0);" class="profilePic floatRight" style="margin: 10px 0 0 5px;"><span class="font11" style="color:#999">by</span> <span class="font12">Myntra</span></a>',
              '</span>',
            '</div>',
            '<div class="floatRight font12" style="margin-top: 14px;">',
              '<span class="howMayLicks color3 floatRight">',
                '<span class="heartIconGray floatLeft" style="margin-right: 3px"></span>',
                '<span class="favCount floatRight">12</span>',
              '</span>',
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
		$(this.el).draggable({
			stop : function(){
				$('.mainWrapper').masonry('reload');
			}
		});
		return this;
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

