package {
	import flash.display.*;
	import flash.events.*;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import flash.filters.ColorMatrixFilter;

	[SWF(frameRate=24, background=0x000000)]
	public class Histogram extends Sprite {

		private var redFilter:ColorMatrixFilter = new ColorMatrixFilter([
			1, 0, 0, 0, 0,
			1, 0, 0, 0, 0,
			1, 0, 0, 0, 0,
			0, 0, 0, 1, 0
		]);

		private var greenFilter:ColorMatrixFilter = new ColorMatrixFilter([
			0, 1, 0, 0, 0,
			0, 1, 0, 0, 0,
			0, 1, 0, 0, 0,
			0, 0, 0, 1, 0
		]);

		private var blueFilter:ColorMatrixFilter = new ColorMatrixFilter([
			0, 0, 1, 0, 0,
			0, 0, 1, 0, 0,
			0, 0, 1, 0, 0,
			0, 0, 0, 1, 0
		]);

		public function Histogram () {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();

//			s.scaleX = stage.stageWidth / 0x100;
//			s.scaleY = stage.stageHeight / 100;

			var url:String = loaderInfo.parameters['url'];

			// url ="http://localhost/tmp/hist/2425207410_03b24e57b9.jpg";
			// url = "http://farm4.static.flickr.com/3048/2425207410_03b24e57b9.jpg";

			// log(url);
			var loader:Loader  = new Loader();
			var req:URLRequest = new URLRequest(url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, drawHistograms);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (e:Event):void {
				// log(e);
			});

			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile = true;
			loader.load(req, context);
		}


		private function drawHistograms (e:Event):void {
				var loader:Loader = Loader(e.target.loader);
				var image:Bitmap  = Bitmap(loader.content);

				var cmfs:Array = [
					{
						name : "Red",
						color : 0xcc0000,
						filter : redFilter
					},
					{
						name : "Green",
						color : 0x009900,
						filter : greenFilter
					},
					{
						name : "Blue",
						color : 0x0000cc,
						filter : blueFilter
					},
				];

				for (var i:uint = 0; i < cmfs.length; i++) {
					var s:Sprite = new Sprite();
					addChild(s);
					with (s.graphics) {
						lineStyle(1);
						beginFill(0xffffff);
						drawRect(0, 0, 0x100, 100);
						endFill();
					}

					s.graphics.lineStyle(1, cmfs[i].color);
					createHistogram(image.bitmapData, s, cmfs[i].filter);

					with (s.graphics) {
						lineStyle(1);
						drawRect(0, 0, 0x100, 100);
					}
					s.y = i * 110;
				}

		}

		// http://d.hatena.ne.jp/nitoyon/20071009/as3_histogram1
		// ヒストグラムを作成する
		private function createHistogram(bmd:BitmapData, s:Sprite, cmf:ColorMatrixFilter):void {
			var bmd2:BitmapData = bmd.clone();
			bmd2.applyFilter(bmd2, bmd2.rect, new Point(), cmf);

			// threshold でカウント
			var values:Array = [];
			for (var i:int = 0; i < 0x100; i++) {
				values[i] = bmd2.threshold(bmd2, bmd2.rect, new Point(), "==", i, 0, 0xff, false);
			}
			bmd2.dispose();

			// 描画
			var max:int = bmd.width * bmd.height / 50;
			var g:Graphics = s.graphics;
			for (i = 0; i < 0x100; i++) {
				g.moveTo(i, 100);
				g.lineTo(i, Math.max(0, 100 - values[i] / max * 100));
			}
		}
	}
}
