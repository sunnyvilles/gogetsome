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
			console.log(config.authResponse);
			that.el.html(that.loggedInTemplate(config.authResponse));
			that.el.fadeIn('slow');
		})
	},
	initialize : function(config){
		hub.on('authed',this.updateHeader,this);
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
		hub.on('authed',this.destroy,this);
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
		hub.on('authed',this.showCustomWall,this);
		hub.on('guestInit',this.showGuestWall,this);
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
				$('.mainWrapper').masonry({
					// options
					itemSelector : '.tile',
					columnWidth : 270
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
        '<div class="modal-media wrapper cboxElement">',
          '<a data-main-img="" href="javascript:void" onclick="">',
            '<img width="240" src="http://25.media.tumblr.com/tumblr_llgnx3XlDx1qjrdlbo1_250.jpg" alt="">',
            '<span class="displayNone type searchIcon"></span>',
          '</a>',
          '<div class="socialToolbar socialLinks forLiveFeeds showtoolbar displayNone" style="">',
            '<span class="floatLeft" style="margin-top: 8px;margin-left: 5px;background: green">',
              '<a href="https://twitter.com/share" class="twitter-share-button" data-url="http://picsfustion.com" data-via="picsfusion" data-hashtags="pics">Tweet</a>',
            '</span>',
            '<span class="floatLeft flike" style="margin-top: 8px;margin-left: 5px;background: green">',
              '<fb:like allowtransparency="true" frameborder="0" scrolling="no" colorscheme="light" action="like" show-faces="false" layout="button_count" href="http://fab.com/sale/6370/product/141752/?fref=fb-like" class=" fb_edge_widget_with_comment fb_iframe_widget"><span style="height: 0px; width: 90px;">',
                  '<iframe scrolling="no" id="f2d26674652832" name="f77b5062c4bfac" style="border: medium none; overflow: hidden; height: 0px; width: 90px;" title="Like this content on Facebook." class="fb_ltr   " src=""></iframe></span></fb:like></span></span>',
          '</div>',
          '<div class="typeInfo clear">',
            '<div class="floatLeft">',
              '<span class="updatedBy box morphing-glowing floatLeft"  style="width: 111px;">',
                '<a href="javascript:void(0);">',
                  '<span class="image-wrap " style="position:relative; display:inline-block; background:url(file:///Users/saorabhkumar/Desktop/testPic/images/sao.jpg) no-repeat center center; width: 40px; height: 40px;">',
                    '<img width="40" height="40" src="" style="opacity: 0; ">',
                  '</span>',
                '</a>',
                '<a href="javascript:void(0);" class="profilePic floatRight" style="margin: 10px 0 0 5px;"><span class="font11" style="color:#999">by</span> <span class="font12">saorabh</span></a>',
              '</span>',
            '</div>',
            '<div class="floatRight font12" style="margin-top: 14px;">',
              '<span class="updatedAt color3 floatLeft" style="margin-right: 5px"><span class="font11" style="color:#999">on </span>May,12 2012</span>',
              '<span class="howMayLicks color3 floatRight">',
                '<span class="heartIconGray floatLeft" style="margin-right: 3px"></span>',
                '<span class="favCount floatRight">12</span>',
              '</span>',
            '</div>',
          '</div>',
        '</div>',
      '</div>'].join(""));
		this.model = config;
		return this;
	},
	render : function(){
		$(this.el).html(this.template(this.model.toJSON()));
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
	
	hub.on('guestInit',app.showGuestContent,app);
})

