
public class tester {

	public tester() {
		System.out.println("hello!");
	}
	
	public static void stuff () {
		System.out.println("called upon");
	}
	
	public static double[] elemWiseMult(double[] a, double[] b) {
		if (a.length != b.length) throw new RuntimeException("bad entries");
		
		double[] res = new double[a.length];
		
		for (int i = 0; i < a.length; i++) {
			res[i] = a[i]*b[i];
		}
		return res;
		
	}
	
}
