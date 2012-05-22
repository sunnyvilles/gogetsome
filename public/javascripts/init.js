/*****************Model Definitions*******************/

var Picture = Backbone.Model.extend({
	initialize : function(config){
        
	}
});
var User = Backbone.Model.extend({
	initialize : function(config){

	},
	isAuthed : function(){
		return false;
	}
});
/*******************Collection Definitins********************/
var PictureCollection = Backbone.Collection.extend({
	initialize : function(config){
        
	}
});


/*******************Views Definitions*************************/
var Header = Backbone.View.extend({
	initialize : function(config){
		this.loggedOutTemplate = _.template([].join(''));
		this.loggedInTemplate = _.template([].join(''));
	},
	render : function(config){
		if(config.user && config.user.isAuthed()){
			$('header').html(this.loggedInTemplate(user));
		}else{
			$('header').html(this.loggedOutTemplate());
		}
	}
});
var LoginPanel = Backbone.View.extend({
	initialize : function(){
		this.template = _.template(["<div>",
			"<div class='fb-login-button'>Login with Facebook</div>",
			"</div>"].join(""));

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
						FB.getLoginStatus(function(response) {
							if(response.status === "connected"){
							//change view to logged in status
							}else{
								FB.Event.subscribe('auth.statusChange', function(response) {
									if(response.status === "connected"){
								//change view to logged in status
								}
								});
							}
						});
					}
				},100);
			};
			d.getElementsByTagName('head')[0].appendChild(js);
		}(document));

		
		return this;
	},
	render : function(){
		$('#wrapper').html(this.template({}));
		return this;
	}
});

var TabPanel = Backbone.View.extend({
    
	});

var PictureWall = Backbone.View.extend({
    
	});

var PictureTile = Backbone.View.extend({
    
	});
$(function(){
	var app = (function(){
		var user = new User({}),loginPanel,header,pictureWall;
		if(user.isAuthed()){
			pictureWall = new PictureWall({
				user : user
			});
			pictureWall.render();
		}else{
			loginPanel = new LoginPanel({
				user : user
			});
			loginPanel.render();
		}
		header = new Header({
			user : user
		});
		header.render({
			user : user
		});
		return {
			getUser : function(){
				return user;
			}
		};
	})();
	
})

