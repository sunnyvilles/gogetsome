//"use strict"
$.Mason.prototype.sort = function(){
	if(app.getSortingOrder()){
		var sortBy = app.getSortingOrder().sortBy;
		var ascending = app.getSortingOrder().sortingOrder;
		this.$bricks = this.$bricks.sort(function(a,b){
			if(sortBy === "price"){
				if(ascending){
					return parseInt($(a).attr('price') || 0) - parseInt($(b).attr('price') || 0);
				}else{
					return parseInt($(b).attr('price') || 0) - parseInt($(a).attr('price') || 0);
				}
			}else if(sortBy === "popularity"){
				if(ascending){
					return  parseInt($(b).attr('popularityIndex') || 0) - parseInt($(a).attr('popularityIndex') || 0);
				}else{
					return  parseInt($(a).attr('popularityIndex') || 0) - parseInt($(b).attr('popularityIndex') || 0);
				}
			}else{
				return 0;
			}
		});
	}
	this._init( function(){} );
};
$.Mason.prototype.resize = function() {
	this._getColumns();
	this._reLayout();
};
/*$.Mason.prototype._reLayout = function( callback ) {
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
	
};*/
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
			'<h1 class="logo floatLeft"><a href="http://graboard.cm" >Rumba</a></h1>',
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
			'<h1 class="logo floatLeft"><a><!--Graboard--></a></h1>',
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
			//FB.XFBML.parse();
			});
		}

		$('.noAuthBox .pullBtn').click(function(){
			var $noAuthBox = $('.noAuthBox');
			$noAuthBox.attr('collapsed',$noAuthBox.attr('collapsed') === "true" ? "false" : "true");
			var that = this;
			$(this).parent().animate({
				top : $noAuthBox.attr('collapsed') === "true" ? 10 : 60
			},{
				duration : 500,
				specialEasing :{
					top : 'easeOutBounce'
				},
				complete : function(){
					if($noAuthBox.attr('collapsed') === "true"){
						$('.pullDown').show();

					}else{
						$('.pullDown').hide();
					}
				}
			});
		})
	}
});

var FilterPanel = Backbone.View.extend({
	siteLogo : {
		1 : 'http://upload.wikimedia.org/wikipedia/commons/3/30/Myntra-Logo.png',
		2 : 'http://img.hahacouponcodes.com/advertiserLogos/71.jpg',
		3 : 'http://upload.wikimedia.org/wikipedia/commons/7/79/Yebhi.com_Official_Logo.jpg',
		4 : 'http://cdn9.savingmore.in/wp-content/uploads/2011/12/craftsvilla-logo.gif'
		
	},
	initialize : function(config){
		this.priceRanges = {
			1 : {
				min : 0,
				max : 500
			},
			2 : {
				min : 501,
				max : 1000
			},
			3 : {
				min : 1001,
				max : 2000
			},
			4 : {
				min : 2001,
				max : 100000
			}
		};
		this.filters = [];
		this.template = _.template([
			'<div id="filterSale" class="bar">',
			'<div class="bar-section bar-section-view">',
			'<label style="margin-top: 5px;">View:</label>',
			'<ul>',
			'<li>',
			'<div class="mainCategory category">',
			'<span class="mainCatList"></span><div>All</div>',
			'<em class="tringle"></em>',
			'<ul class="subCatLists displayNone">',
			'<li><a class="cat cat1" data-category="10302"><span></span><div>Shoes</div></a></li>',
			'<li><a class="cat cat2" data-category="8047"><span></span><div>Men</div></a></li>',
			'<li><a class="cat cat3" data-category="6857"><span></span><div>Vintage</div></a></li>',
			'<li><a class="cat cat4" data-category="6875"><span></span><div>Jewellery</div></a></li>',
			'<li><a class="cat cat5" data-category="13819"><span></span><div>Home</div></a></li>',
			'<li><a class="cat cat6" data-category="12916"><span></span><div>Watches</div></a></li>',
			'<li><a class="cat cat7" data-category="14883"><span></span><div>Kids</div></a></li>',
			'<li><a class="cat cat7" data-category="25"><span></span><div>Women</div></a></li>',
			'</ul>',
			'</div>',
			'</li>',
			'<li>',
			'<div class="mainCategory price">',
			'<span class="mainCatList"></span>',
			'<div>Price</div>',
			'<em class="tringle"></em>',
			'<ul class="subCatLists priceList displayNone">',
			'<li><a class="cat1" data-category="1"><span></span><div>0-500</div></a></li>',
			'<li><a class="cat2" data-category="2"><span></span><div>500-1000</div></a></li>',
			'<li><a class="cat3" data-category="3"><span></span><div>1000-2000</div></a></li>',
			'<li><a class="cat4" data-category="4"><span></span><div>2000+</div></a></li>',
			'</ul>',
			'</div>',
			'</li>',
			'</ul>',
			'<label style="margin-top: 5px;">Sort By:</label>',
			'<div class="sortByPrice grabIt"><a class="a_demo_four" style="line-height: 19px;" href="javascript:void(0);">Price</a></div>',
			'<div class="sortByPop grabIt"><a class="a_demo_four" style="line-height: 19px;" href="javascript:void(0);">discount</a></div>',
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
			that.addFilter(e,this);
		});
		$('.category').on('mouseover',function(){
			$('.category .subCatLists').show();
		});
		$('.category').on('mouseout',function(){
			$('.category .subCatLists').hide();
		});

		$('.price').on('mouseover',function(){
			$('.price .subCatLists').show();
		});
		$('.price').on('mouseout',function(){
			$('.price .subCatLists').hide();
		});


		$('.sortByPrice',this.el).click(function(){
			that.sort("price",this);
		});
		$('.sortByPop',this.el).click(function(){
			that.sort("popularity",this);
		});
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
		$('label,ul:not(.subCatLists),#filterSale .grabIt',this.el).show();
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
			$('#filterSale label,#filterSale ul:not(.subCatLists),#filterSale .grabIt',this.el).hide();
			$('.showhide em',that.el).removeClass('rightArrow').addClass('leftArrow');
			$('.showhide',that.el).css({
				'float' : 'left'
			})
		});
	},
	processResponse : function(res){
		var categories = {};
		var temp = {};
		for (i = 0; i < res.categories.length; i++) {
			if(categories[res.categories[i].product_id]){
				categories[res.categories[i].product_id].push(res.categories[i].category_id);
			}else{
				categories[res.categories[i].product_id] = [];
				categories[res.categories[i].product_id].push(res.categories[i].category_id);
			}

			if(temp[res.categories[i].category_id]){
				temp[res.categories[i].category_id] = temp[res.categories[i].category_id] + 1;
			}else{
				temp[res.categories[i].category_id] = 1
			}
		}
		var products = res.products;
		for (i = 0,len = products.length; i < len; i++) {
			$.extend(products[i],{
				site_name : res.indexed_sites[products[i].site_id].name,
				category : categories[products[i].id] || [],
				site_logo : this.siteLogo[products[i].site_id],
				discount : Math.floor(((products[i].actual_price-products[i].discount_price)/products[i].actual_price)*100)
			})
		}
		return products;
	},
	addFilter : function(event,el){
		var that = this;
		if($(el).hasClass('cat')){
			//filter by category
			$.ajax({
				url : 'data',
				data : {
					data : JSON.stringify(that.filters)
				},
				success : function(res){
					data = that.processResponse(res);
					app.getStore().add(data);
					$('.mainWrapper').masonry('reload');
					$('.category > div').html($('div',el).html());
					$('.category').removeClass().addClass($('span',el).parent().attr('class') + ' mainCategory category selected');
					if(!$('.category > .remove').length){
						$('.category > div').before('<span class="remove"></remove>');
						$('.category > .remove').click(function(){
							that.removeFilter("category",this);
						});
					}
					for(var i = 0;i<that.filters.length;i++){
						if(that.filters[i].type === "category"){
							that.filters.splice(i,1);
						}
					}
					that.filters.push({
						type : "category",
						filterValue : parseInt($(el).attr("data-category"))
					});
				}
			});

		}else{
			//filter by price
			$('.price > div').html($('div',el).html());
			$('.price').removeClass().addClass($('span',el).parent().attr('class') + ' mainCategory price selected');
			if(!$('.price > .remove').length){
				$('.price > div').before('<span class="remove"></remove>');
				$('.price > .remove').click(function(){
					that.removeFilter("price",this);
				});
			}
			for(var i = 0;i<this.filters.length;i++){
				if(this.filters[i].type === "price"){
					this.filters.splice(i,1);
				}
			}
			this.filters.push({
				type : "price",
				filterValue : parseInt($(el).attr("data-category"))
			})
		}
		this.updateWall();
		this.resetSort();
		$('.mainCategory .subCatLists').hide();
	},
	removeFilter : function(filterType,el){
		$(el).remove();
		
		if(filterType === "category"){
			$('.category > div').html("All");
			$('.category').removeClass().addClass('mainCategory category');
			$('.category .subCatLists').hide();
			
			for(var i = 0;i<this.filters.length;i++){
				if(this.filters[i].type === "category"){
					this.filters.splice(i,1);
				}
			}
			$('.category > .remove').remove();
		}else if(filterType === "price"){

			$('.price > div').html("Price");
			$('.price').removeClass().addClass('mainCategory price');
			$('.price .subCatLists').hide();
			
			for(var i = 0;i<this.filters.length;i++){
				if(this.filters[i].type === "price"){
					this.filters.splice(i,1);
				}
			}
			$('.price > .remove').remove();
		}
		this.resetSort();
		this.updateWall();
	},
	updateWall : function(){
		var that = this;
		$("html, body").animate({
			scrollTop: 0
		}, 500,function(){
			var items = [];
			var len = app.getStore().length;
			while(len--){
				var item = app.getStore().at(len);
				var hasCategory = 0;
				for(var i = 0; i < that.filters.length; i++ ){
					if(that.filters[i].type === "category"){
						if(item.get("category").indexOf(that.filters[i].filterValue) !== -1){
							hasCategory++;
						}
					}else if(that.filters[i].type === "price"){
						if(item.get("discount_price") < that.priceRanges[that.filters[i].filterValue].max && item.get("discount_price") > that.priceRanges[that.filters[i].filterValue].min){
							hasCategory++;
						}
					}
					
				}
				if(hasCategory === that.filters.length){
					if(!$('#' + item.get('id')).length){
						item = new PictureTile({
							model : item,
							attributes : {
								id : item.get('id'),
								price : item.get('discount_price'),
								popularityIndex : item.get('discount_percentage')
							}
						});
						item.render();
						$('.mainWrapper').append(item.el);
					}
				}else{
					$('#' + item.get('id')).remove();
				}
			}
			$('.mainWrapper').masonry('reload');
		});
	/*if($('.mainWrapper .masonry').length < 20){
			$.ajax({
				url : '/data',
				data : {
					filter : this.filters
				},
				success : function(){
					
				}
			});
		}*/
	},
	sort : function(sortBy,el){
		this.sortOrder = !this.sortOrder;
		$('.a_demo_four').removeClass('ascending descending');
		if(this.sortOrder){
			$('a',el).addClass('ascending');
		}else{
			$('a',el).addClass('descending');
		}
		
		app.setSortOrder({
			sortBy : sortBy,
			sortingOrder : this.sortOrder
		});
		$('.mainWrapper').masonry('sort');
	},
	resetSort : function(){
		$('.a_demo_four').removeClass('ascending descending');
		this.sortOrder = false;
	}
});

var InvitePanel = Backbone.View.extend({
	initialize : function(){
		this.template = _.template(['<div id="boxes"><div id="invitePanel" class="window lightBox border5">',
			'<div id="container_demo" >',
			'<a class="hiddenanchor" id="toregister"></a>',
			'<a class="hiddenanchor" id="tologin"></a>',
			'<div id="wrapper">',
			'<div id="login" class="animate form">',
			'<form  action="/request-invite"> ',
			'<a href="javascript:void(0);" class="closeMe">X</a>',
			'<h1>Sign up for an invite to join Graboard</h1>',
			'<p>',
			'<label for="emailsignup" class="youmail" data-icon="e" > Your email</label>',
			'<input id="emailsignup" name="emailsignup" required="required" type="email" placeholder="Email"/> ',
			'</p>',
			'<p class="login button"> ',
			'<input type="submit" value="Request an Invite!" />',
			'</p>',
			'<p class="change_link">  ',
			'<!--You are about to get access for GRABOARD!--> Graboard is your personal reporter for daily design inspirations!',
			'<a class="to_register">Invited!</a>',
			'</p>',
			'</form>',
			'</div>',
			'<div id="register" class="animate form">',
			'<form  action=""> ',
			'<a href="javascript:void(0);" class="closeMe">X</a>',
			'<h1>Badhai HO</h1>',
			'<p>',
			'Mil Gaya Mamu Se Milne ka access',
			'</p>',
			'<p class="change_link">  ',
			'Your are about to get access for GRABOARD! :)',
			'</p>',
			'</form>',
			'</div>',
			'</div>',
			'</div>',
			'</div>  ',
			"</div><div id='mask'></div></div>"].join(""));
		return this;
	},
	render : function(){
		var that = this;
		if($('.loginPanel').length){
			return null;
		}
		$(document).keyup(function(e) {
			if (e.keyCode == 27) {
				$('.close',that.el).trigger('click');
			}
		});
		$('body').prepend(this.template({}));
		this.el = $('#invitePanel');
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
		$('form', this.el).on('submit',function(e){
			that.submit(e,this)
		})
	},
	submit : function(e,form){
		e.preventDefault();
		var anm = $('.change_link',this.el);
		anm.addClass('animateProgressBar');
		$.ajax({
			url : $(form).attr('action'),
			data : {
				email : $('#emailsignup',form).val()
			},
			success : function(resp){
				anm.removeClass('animateProgressBar');
				$('#emailsignup',form).val("");
				if(!resp.err_msg){
					$('.change_link',form).html("Thank you! share this url with your friends to get an early access <span class='link'>" + "http://graboard.com/" + resp.invitation_code + "</span>");
				}else{
					$('.change_link',form).html(resp.err_msg[0]);
				}
			}
		})
	}
});
var LoginPanel = Backbone.View.extend({
	initialize : function(){
		hub.bind('authed',this.destroy,this);
		var that = this;

		this.template = _.template(['<div id="boxes"><div id="loginPanel" class="window lightBox border5">',
			'<div id="container_demo" >',
			'<a class="hiddenanchor" id="toregister"></a>',
			'<a class="hiddenanchor" id="tologin"></a>',
			'<div id="wrapper">',
			'<div id="login" class="animate form">',
			'<form  action="" autocomplete="on"> ',
			'<a href="javascript:void(0);" class="closeMe">X</a>',
			'<h1>Log in</h1> ',
			'<div class="socialButtons">',
			'<div class="btn fbBtn">',
			'<a class="fb loginButton facebookButton border5">',
			'<div class="logoWrapper"></div>',
			'</a>',
			'</div>',
			'<div class="btn">',
			'<a class="tw loginButton twitterButton border5" href="/twitter-connect">',
			'<div class="logoWrapper"></div>',
			'</a>',
			'</div>',
			'</div>',
			'<div class="clear"></div>',
			'<p> ',
			'<label for="username" class="uname" data-icon="u" > Your email or username </label>',
			'<input id="username" name="username" required="required" type="text" placeholder="myusername or mymail@mail.com"/>',
			'</p>',
			'<p> ',
			'<label for="password" class="youpasswd" data-icon="p"> Your password </label>',
			'<input id="password" name="password" required="required" type="password" placeholder="eg. X8df!90EO" /> ',
			'</p>',
			'<p class="keeplogin"> ',
			'<input type="checkbox" name="loginkeeping" id="loginkeeping" value="loginkeeping" /> ',
			'<label for="loginkeeping">Keep me logged in</label>',
			'</p>',
			'<p class="login button"> ',
			'<input type="submit" value="Login" /> ',
			'</p>',
			'<p class="change_link">',
			'Not a member yet ?',
			'<a class="to_register">Request an Invite!</a>',
			'</p>',
			'</form>',
			'</div>',
			'<div id="register" class="animate form">',
			'<form  action=""> ',
			'<a href="javascript:void(0);" class="closeMe">X</a>',
			'<h1>Invite Me</h1>',
			'<p>',
			'<label for="emailsignup" class="youmail" data-icon="e" > Your email</label>',
			'<input id="emailsignup" name="emailsignup" required="required" type="email" placeholder="mysupermail@mail.com"/> ',
			'</p>',
			'<p class="login button"> ',
			'<input type="submit" value="Request an Invite!" />',
			'</p>',
			'<p class="change_link">  ',
			'Your are about to get access for GRABOARD! :)',
			'</p>',
			'</form>',
			'</div>',
			'</div>',
			'</div>  ',
			"</div><div id='mask'></div></div>"].join(""));
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
		
	},
	destroy : function(){
		$('.loginPanel').remove();
	}
});

var TabPanel = Backbone.View.extend({

	});

var PictureWall = Backbone.View.extend({
	siteLogo : {
		1 : 'http://upload.wikimedia.org/wikipedia/commons/3/30/Myntra-Logo.png',
		2 : 'http://img.hahacouponcodes.com/advertiserLogos/71.jpg',
		3 : 'http://upload.wikimedia.org/wikipedia/commons/7/79/Yebhi.com_Official_Logo.jpg',
		4 : 'http://www.craftsvilla.com/favicon.ico',
		5 : 'http://cdn.firstcry.com/brainbees/images/FC_favicon_01.ico',
		6 : 'http://upload.wikimedia.org/wikipedia/commons/7/79/Yebhi.com_Official_Logo.jpg'
	},
	initialize : function(){
		hub.bind('authed',this.showCustomWall,this);
		hub.bind('guestInit',this.showGuestWall,this);
		
		this.items = [];
	},
	initInfiniteScroll : function(){
		//init infinite scroll
		$('.mainWrapper').infinitescroll({
			navSelector  : "div.pagination",
			// selector for the paged navigation (it will be hidden)
			nextSelector : "div.pagination a:first",
			// selector for the NEXT link (to page 2)
			itemSelector : ".mainWrapper div.tile",
			// selector for all items you'll retrieve
			debug : true
		});
	},
	render : function(){

	},
	showCustomWall : function(){
		var that = this;
		$('.mainWrapper').activity();
		$.ajax({
			url : '/data',
			success : function(res){
				var categories = {};
				var temp = {};
				for (i = 0; i < res.categories.length; i++) {
					if(categories[res.categories[i].product_id]){
						categories[res.categories[i].product_id].push(res.categories[i].category_id);
					}else{
						categories[res.categories[i].product_id] = [];
						categories[res.categories[i].product_id].push(res.categories[i].category_id);
					}

					if(temp[res.categories[i].category_id]){
						temp[res.categories[i].category_id] = temp[res.categories[i].category_id] + 1;
					}else{
						temp[res.categories[i].category_id] = 1
					}
				}
				console.log(categories);
				console.log(temp);
				that.populateWall(res.products,res.indexed_sites,categories);
			},
			error : function(){
			//TODO show error message
			}
		});
	},
	populateWall : function(products,indexed_sites,categories){
		var that = this;
		
		$('.mainWrapper').activity(false);
		app.getStore().reset(products);
		//$('.mainWrapper').append("<div class='wishList'> Watched Items</div>");
		$('.wishList').droppable({
			drop : function(event,ui){
				var item = $(ui.draggable).detach();
				item.removeClass('tile');
				item.css({
					height: 64,
					width : 64,
					overflow : 'hidden'
				});
				$('.wishList').append(item);
				$('.mainWrapper').masonry('reload');
			}
		});
		for(var i=0,len=app.getStore().length;i<len;i++){
			var model = app.getStore().at(i);
			model.set({
				site_name : indexed_sites[model.get('site_id')].name,
				category : categories[model.get('id')] || [],
				site_logo : that.siteLogo[model.get('site_id')],
				discount : Math.floor(((model.get('discount_price') - model.get('actual_price'))/model.get('discount_price'))*100)
			});
			var item = new PictureTile({
				model : model,
				attributes : {
					id : model.get('id'),
					price : model.get('discount_price'),
					popularityIndex : model.get('discount_percentage')
				}
			});
			item.render();
			$('.mainWrapper').append(item.el);
			that.items.push(item);
			
		}
		this.initInfiniteScroll();
		$('.mainWrapper').imagesLoaded(function(){

			$('.mainWrapper').masonry({
				itemSelector : '.tile',
				columnWidth : 270,
				cornerStampSelector: '.wishList'
			});
		});
		
	},
	showGuestWall : function(){
		var that = this;
		$('.mainWrapper').activity();
		$.ajax({
			url : '/data',
			success : function(res){
				var categories = {};
				var temp = {};
				for (i = 0; i < res.categories.length; i++) {
					if(categories[res.categories[i].product_id]){
						categories[res.categories[i].product_id].push(res.categories[i].category_id);
					}else{
						categories[res.categories[i].product_id] = [];
						categories[res.categories[i].product_id].push(res.categories[i].category_id);
					}

					if(temp[res.categories[i].category_id]){
						temp[res.categories[i].category_id] = temp[res.categories[i].category_id] + 1;
					}else{
						temp[res.categories[i].category_id] = 1
					}
				}
				console.log(categories);
				console.log(temp);
				that.populateWall(res.products,res.indexed_sites,categories);
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
			'<a class="imgContent" href="<%=url%>">',
			'<img width="240" src="<%=primary_image_url%>" alt="">',
			'</a>',

			'<div class="mask">',
			'<div class="itemDisc">',
			'<span class="itemName"><%=brand%></span>',
			'<span class="itemNameDesc"><%=name%></span>',
			'<div class="priceDetails">',
			'<div class="floatLeft">',
			'<span class="discountedPrice red">Rs. <%=discount_price%> <span class="strike gray originalPrice"><%=actual_price || discount_price%></span></span>',
			'<div class="perOff red fontBold">(<%=discount_percentage%>% OFF)</div>',
			'</div>',
			'<div class="floatRight">',
			'<a class="grabIt " target="_self" href="javascript:void(0);"><span class="left"> Grab It! </span></a>',
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
			'<span class="image-wrap " style="position:relative; display:inline-block; background:url(<%=site_logo%>) no-repeat center center; background-size: 25px 25px;width: 25px; height: 25px;">',
			'<img width="40" height="40" src="<%=site_logo%>" style="opacity: 0; ">',
			'</span>',
			'</a>',
			'<a href="javascript:void(0);" class="profilePic floatRight" style="margin: 10px 0 0 5px;"><span class="font11" style="color:#999">by</span> <span class="font12"><%=site_name%></span></a>',
			'</span>',
			'</div>',
			'<div class="floatRight font12" style="margin-top: 14px;">',
			'<span class="howMayLicks color3 floatRight">',
			'<span class="heartIconGray floatLeft" style="margin-right: 3px"></span>',
			'<span class="favCount floatRight"><%=1%></span>',
			'</span>',
			'</div>',

			'<div class="clear"></div>',
			'<div class="itemDisc onMainSaleWall" style="padding: 0 5px 10px;">',
			'<span class="itemName" style="width:200px; display: block;font-size:13px;"><%=brand%></span>',
			'<span class="itemNameDesc"  style="display: block;font-size:12px;"><%=name%></span>',
			'<div class="priceDetails" style="height: 25px;padding-top: 4px;">',
			'<div class="floatLeft">',
			'<div class="perOff red fontBold" style="font-size:11px;">(<%=discount_percentage%>% OFF) Rs. <%=discount_price%> </div>',
			'</div>',
			'<div class="floatRight displayNone grabButton">',
			'<a class="grabIt " style="height: 10px;line-height: 8px;"target="_self" href="javascript:void(0);"><span style="color:#fff;" class="left"> Grab It! </span></a>',
			'</div>',
			'</div>',
			'</div>',
			'</div>',
			'</div>',
			'</div>'
			].join(""));

		//this.model = config;
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
		/*var item = $(this.el).fadeOut('slow',function(){
			var pr = item.detach();
			$('.mainWrapper').masonry('reload');
			
			$('.wishList').append(pr.fadeIn('fast',function(){
				pr.removeClass('tile ui-draggable masonry-brick').css({
					position  :'relative',
					top : 0,
					left : 0
				});
				$('.mainWrapper').masonry('reload');
			}));
		});*/
		window.open('/rh?rd_url=' +  this.model.get('url'));
		
	},
	addToWishList : function(){

	}
});
$(function(){
	hub = {};
	_.extend(hub, Backbone.Events);
	app = (function(config){
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

				var checkInitId = setTimeout(function(){					
					clearInterval(checkInitId);
					//check whether logged in or not
					/*FB.getLoginStatus(function(response) {
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
					});*/
					
					hub.trigger("guestInit",{});
					
				},2000);

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
			user : user,
			categories : []
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

			},
			setSortOrder : function(sort){
				this.sortingOrder = sort;
			},
			getSortingOrder : function(){
				return this.sortingOrder;
			}
		};
	})({
		categories : $('#categories').val()
	});

	hub.bind('guestInit',app.showGuestContent,app);
});