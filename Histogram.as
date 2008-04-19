package {
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.geom.Point;
	import flash.filters.ColorMatrixFilter;

	[SWF(frameRate=24, background=0x000000)]
	public class Histogram extends Sprite {

		public function Histogram () {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;

			graphics.beginFill(0xffffff);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			graphics.endFill();

			var s:Sprite = new Sprite();
			s.scaleX = stage.stageWidth / 0x100;
			s.scaleY = stage.stageHeight / 100;
			addChild(s);

			var loader:Loader  = new Loader();
			var req:URLRequest = new URLRequest(loaderInfo.parameters['url']);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (event:Event):void {
				var loader:Loader = Loader(event.target.loader);
				var image:Bitmap  = Bitmap(loader.content);

				createHistogram(image.bitmapData, s);
			});
			loader.load(req);
		}

		// http://d.hatena.ne.jp/nitoyon/20071009/as3_histogram1
		// ヒストグラムを作成する
		private function createHistogram(bmd:BitmapData, s:Sprite):void {
			// グレースケール化
			var cmf:ColorMatrixFilter = new ColorMatrixFilter(
				[
					1 / 3, 1 / 3, 1 / 3, 0, 0,
					1 / 3, 1 / 3, 1 / 3, 0, 0,
					1 / 3, 1 / 3, 1 / 3, 0, 0
				]
			);
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
			s.graphics.lineStyle(1);
			for (i = 0; i < 0x100; i++) {
				s.graphics.moveTo(i, 100);
				s.graphics.lineTo(i, Math.max(0, 100 - values[i] / max * 100));
			}
		}
	}
}
