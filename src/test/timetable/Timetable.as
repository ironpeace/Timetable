package test.timetable
{
	import muit.timetable.Timetable;
	
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	public class Timetable
	{	
		
		[Before]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}

		// 列が違ったらとにかく　Flase
		[Test]
		public function testIsCollidedImpl_1():void
		{
			trace("testIsCollidedImpl_1");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertFalse(t.isCollidedImpl(1, 0, 0, 2, 0, 0));
		}
		
		//　上下でボックスが綺麗に分離しているケース
		[Test]
		public function testIsCollidedImpl_2():void
		{
			trace("testIsCollidedImpl_2");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertFalse(t.isCollidedImpl(0, 1, 2, 0, 3, 4));
		}

		// 下上でボックスが綺麗に分離しているケース
		[Test]
		public function testIsCollidedImpl_3():void
		{
			trace("testIsCollidedImpl_3");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertFalse(t.isCollidedImpl(0, 3, 4, 0, 1, 2));
		}
		
		//　上下でボックスがくっついているケース
		[Test]
		public function testIsCollidedImpl_4():void
		{
			trace("testIsCollidedImpl_4");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertTrue(t.isCollidedImpl(0, 1, 2, 0, 2, 3));
		}
		
		// 下上でボックスがくっついているケース
		[Test]
		public function testIsCollidedImpl_5():void
		{
			trace("testIsCollidedImpl_5");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertTrue(t.isCollidedImpl(0, 2, 3, 0, 1, 2));
		}

		//　上下でボックスが重なっているケース
		[Test]
		public function testIsCollidedImpl_6():void
		{
			trace("testIsCollidedImpl_6");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertTrue(t.isCollidedImpl(0, 1, 3, 0, 2, 4));
		}
		
		// 下上でボックスが重なっているケース
		[Test]
		public function testIsCollidedImpl_7():void
		{
			trace("testIsCollidedImpl_7");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertTrue(t.isCollidedImpl(0, 2, 4, 0, 1, 3));
		}
		
		//　rb1 が rb2　を覆っているケース
		[Test]
		public function testIsCollidedImpl_8():void
		{
			trace("testIsCollidedImpl_8");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertTrue(t.isCollidedImpl(0, 1, 4, 0, 2, 3));
		}
		
		//　rb2 が rb1　を覆っているケース
		[Test]
		public function testIsCollidedImpl_9():void
		{
			trace("testIsCollidedImpl_9");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertTrue(t.isCollidedImpl(0, 2, 3, 0, 1, 4));
		}

		//　rb2 が 1セルで、rb1　のすぐ隣にいるケース
		[Test]
		public function testIsCollidedImpl_10():void
		{
			trace("testIsCollidedImpl_10");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertFalse(t.isCollidedImpl(0, 2, 3, 0, 1, 1));
		}
		
		//　rb2 が 1セルで、rb1　のすぐ隣にいるケース
		[Test]
		public function testIsCollidedImpl_11():void
		{
			trace("testIsCollidedImpl_11");
			var t:muit.timetable.Timetable = new muit.timetable.Timetable();
			assertFalse(t.isCollidedImpl(0, 2, 3, 0, 4, 4));
		}

	}
}