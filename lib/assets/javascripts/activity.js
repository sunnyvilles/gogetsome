/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
(function($){
	$.fn.activity = function(config){
		if(config !== false){
			var loaderTemplate = ["<span class='loader'><img src='/images/sq-loader.gif' /></span>"];
			this.append(loaderTemplate.join(''));
		}else{
			$('.loader',this).remove();
		}
	}
})(jQuery);