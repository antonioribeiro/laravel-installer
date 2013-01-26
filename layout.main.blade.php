<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title>Bootstrap, from Twitter</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="description" content="">
	<meta name="author" content="">

	<!-- Le styles -->
	<link href="assets/css/bootstrap.min.css" rel="stylesheet">
	<style type="text/css">
      body {
        padding-top: 60px;
        padding-bottom: 40px;
      }
    </style>

	<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
	<!--[if lt IE 9]>
	<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
	<![endif]-->

	<!-- Fav and touch icons -->
	<link rel="apple-touch-icon-precomposed" sizes="144x144" href="../assets/ico/apple-touch-icon-144-precomposed.png">
	<link rel="apple-touch-icon-precomposed" sizes="114x114" href="../assets/ico/apple-touch-icon-114-precomposed.png">
	<link rel="apple-touch-icon-precomposed" sizes="72x72" href="../assets/ico/apple-touch-icon-72-precomposed.png">
	<link rel="apple-touch-icon-precomposed" href="../assets/ico/apple-touch-icon-57-precomposed.png">
	<link rel="shortcut icon" href="../assets/ico/favicon.png">
	<script>window["_GOOG_TRANS_EXT_VER"] = "1";</script>
</head>

<body>

	<div class="navbar navbar-inverse navbar-fixed-top">
		<div class="navbar-inner">
			<div class="container">
				<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
					<span class="icon-bar"></span>
				</a>
				<a class="brand" href="#">Project name</a>
				<div class="nav-collapse collapse">
					<ul class="nav">
						<li class="active">
							<a href="#">Home</a>
						</li>
						<li>
							<a href="#about">About</a>
						</li>
						<li>
							<a href="#contact">Contact</a>
						</li>
						<li class="dropdown">
							<a href="#" class="dropdown-toggle" data-toggle="dropdown">
								Dropdown <b class="caret"></b>
							</a>
							<ul class="dropdown-menu">
								<li>
									<a href="#">Action</a>
								</li>
								<li>
									<a href="#">Another action</a>
								</li>
								<li>
									<a href="#">Something else here</a>
								</li>
								<li class="divider"></li>
								<li class="nav-header">Nav header</li>
								<li>
									<a href="#">Separated link</a>
								</li>
								<li>
									<a href="#">One more separated link</a>
								</li>
							</ul>
						</li>
					</ul>
					<form class="navbar-form pull-right">
						<input class="span2" type="text" placeholder="Email">
						<input class="span2" type="password" placeholder="Password">
						<button type="submit" class="btn">Sign in</button>
					</form>
				</div>
				<!--/.nav-collapse -->
			</div>
		</div>
	</div>

	<div class="container">

		<!-- Main hero unit for a primary marketing message or call to action -->
		<div class="hero-unit">
			@yield('content')
		</div>

		<!-- Example row of columns -->
		<div class="row">
			<div class="span4">
				<h2>Heading</h2>
				<p>
					Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.
				</p>
				<p>
					<a class="btn" href="#">View details</a>
				</p>
			</div>
			<div class="span4">
				<h2>Heading</h2>
				<p>
					Donec id elit non mi porta gravida at eget metus. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus. Etiam porta sem malesuada magna mollis euismod. Donec sed odio dui.
				</p>
				<p>
					<a class="btn" href="#">View details</a>
				</p>
			</div>
			<div class="span4">
				<h2>Heading</h2>
				<p>
					Donec sed odio dui. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Vestibulum id ligula porta felis euismod semper. Fusce dapibus, tellus ac cursus commodo, tortor mauris condimentum nibh, ut fermentum massa justo sit amet risus.
				</p>
				<p>
					<a class="btn" href="#">View details</a>
				</p>
			</div>
		</div>

		<hr>

		<footer>
			<p>© Company 2012</p>
		</footer>

	</div>
	<!-- /container -->

	<!-- Le javascript
    ================================================== -->
	<!-- Placed at the end of the document so the pages load faster -->
    <script src="http://code.jquery.com/jquery-latest.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>

	<a class="hiddenlink" href="#" accesskey="t"></a>
	<div style="display: none;" id="hiddenlpsubmitdiv"></div>
	<script>try{for(var lastpass_iter=0; lastpass_iter < document.forms.length; lastpass_iter++){ var lastpass_f = document.forms[lastpass_iter]; if(typeof(lastpass_f.lpsubmitorig2)=="undefined"){ lastpass_f.lpsubmitorig2 = lastpass_f.submit; lastpass_f.submit = function(){ var form=this; var customEvent = document.createEvent("Event"); customEvent.initEvent("lpCustomEvent", true, true); var d = document.getElementById("hiddenlpsubmitdiv"); for(var i = 0; i < document.forms.length; i++){ if(document.forms[i]==form){ d.innerText=i; } } d.dispatchEvent(customEvent); form.lpsubmitorig2(); } } }}catch(e){}</script>
	<script>try{function lpshowmenudiv(id){   closelpmenus(id);   var div = document.getElementById('lppopup'+id);   var btn = document.getElementById('lp'+id);   if(btn && div){     var btnstyle = window.getComputedStyle(btn, null);     var divstyle = window.getComputedStyle(div, null);     var posx = btn.offsetLeft;     posx -= 80;     var divwidth = parseInt(divstyle.getPropertyValue('width'));     if(posx + divwidth > window.innerWidth - 25){       posx -= ((posx + divwidth) - window.innerWidth + 25);     }     div.style.left = posx + "px";     div.style.top = (btn.offsetTop + parseInt(btnstyle.getPropertyValue('height'))) + "px";         if(div.style.display=='block'){div.style.display = 'none'; if(typeof(slideup)=='function'){slideup();} }    else div.style.display = 'block';       } }function closelpmenus(id){   if(typeof(lpgblmenus)!='undefined'){     for(var i=0; i < lpgblmenus.length; i++){       if((id==null || lpgblmenus[i]!='lppopup'+id) && document.getElementById(lpgblmenus[i]))         document.getElementById(lpgblmenus[i]).style.display = 'none';     }   }} var lpcustomEvent = document.createEvent('Event'); lpcustomEvent.initEvent('lpCustomEventMenu', true, true); }catch(e){}</script>
	<script>try{if(typeof(lpgblmenus)=='undefined'){ lpgblmenus = new Array(); }   lpgblmenus[lpgblmenus.length] = 'lppopupautofill';   }catch(e){}</script>
	<script>try{if(typeof(lpgblmenus)=='undefined'){ lpgblmenus = new Array(); }   lpgblmenus[lpgblmenus.length] = 'lppopupnever';   }catch(e){}</script>
	<script>try{document.addEventListener('mouseup', function(e){ if(typeof(closelpmenus)=='function'){closelpmenus();}}, false)}catch(e){}</script>
</body>
</html>