package test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLNonTransientConnectionException;
import java.sql.Statement;

import org.apache.jena.rdf.model.Model;
import org.apache.jena.rdf.model.ModelFactory;
import org.apache.logging.log4j.Level;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.core.config.Configurator;
import org.apache.logging.log4j.core.config.DefaultConfiguration;
import org.junit.BeforeClass;

import junit.framework.TestCase;
import r2rml.engine.Configuration;
import r2rml.engine.R2RMLException;
import r2rml.engine.R2RMLProcessor;

/**
 * Unit test for testing the functionality of this implementation using an
 * in memory database.
 * 
 * @author Christophe Debruyne
 *
 */
public class TestR2RML extends TestCase {

	private static Logger logger = LogManager.getLogger(TestR2RML.class);
	private static String connectionURL = "jdbc:derby:memory:testing";

	public TestR2RML(String testName) {
		super(testName);
	}

	@BeforeClass
	public static void init() throws Exception {
		Configurator.initialize(new DefaultConfiguration());
	    Configurator.setRootLevel(Level.INFO);
	}

	@Override
	protected void setUp() throws Exception {
		super.setUp();

		try {
			logger.info("Starting in-memory database for unit tests");
			Class.forName("org.apache.derby.jdbc.EmbeddedDriver");
			DriverManager.getConnection(connectionURL + ";create=true").close();
		} catch (Exception ex) {
			ex.printStackTrace();
			fail("Exception during database startup.");
		}
		try {
			Connection connection = DriverManager.getConnection(connectionURL);
			Statement statement = connection.createStatement();
			statement.execute("CREATE TABLE DEPT(DEPTNO INT PRIMARY KEY, DNAME VARCHAR(30), LOC VARCHAR(30))");
			statement.execute("CREATE TABLE EMP(EMPNO INT PRIMARY KEY, ENAME VARCHAR(100), JOB VARCHAR(20), DEPTNO INT, FOREIGN KEY (DEPTNO) REFERENCES DEPT(DEPTNO))");
			statement.execute("INSERT INTO DEPT VALUES (10, 'APPSERVER', 'NEW YORK')");
			statement.execute("INSERT INTO EMP VALUES (7369, 'SMITH', 'CLERK', 10)");

			statement.execute("CREATE TABLE DEPT2(DEPTNO INT, DNAME VARCHAR(30), LOC VARCHAR(30))");
			statement.execute("CREATE TABLE EMP2(EMPNO INT, ENAME VARCHAR(100), JOB VARCHAR(20))");
			statement.execute("CREATE TABLE EMP2DEPT(EMPNO INT, DEPTNO INT)");
			statement.execute("INSERT INTO DEPT2 VALUES (10, 'APPSERVER', 'NEW YORK')");
			statement.execute("INSERT INTO DEPT2 VALUES (20, 'RESEARCH', 'BOSTON')");
			statement.execute("INSERT INTO EMP2 VALUES (7369, 'SMITH', 'CLERK')");
			statement.execute("INSERT INTO EMP2 VALUES (7369, 'SMITH', 'NIGHTGUARD')");
			statement.execute("INSERT INTO EMP2 VALUES (7400, 'JONES', 'ENGINEER')");
			statement.execute("INSERT INTO EMP2DEPT VALUES (7369, 10)");
			statement.execute("INSERT INTO EMP2DEPT VALUES (7369, 20)");
			statement.execute("INSERT INTO EMP2DEPT VALUES (7400, 10)");
			statement.close();
			connection.close();

		} catch (Exception ex) {
			ex.printStackTrace();
			fail("Failure setting up the database.");
		}
	}

	@Override
	protected void tearDown() throws Exception {
		super.tearDown();
		logger.info("Stopping in-memory database.");
		try {
			DriverManager.getConnection(connectionURL + ";drop=true").close();
		} catch (SQLNonTransientConnectionException ex) {
			if (ex.getErrorCode() != 45000) {
				throw ex;
			}
			// Shutdown success
		}
	}

	/**
	 * 2.3 Example: Mapping a Simple Table
	 * https://www.w3.org/TR/r2rml/#example-simple
	 */
	public void testExample01() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/01.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/01.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());	
	}

	/**
	 * 2.4 Example: Computing a Property with an R2RML View
	 */
	public void testExample02() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/02.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/02.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());	
	}

	/**
	 * 2.5 Example: Linking Two Tables
	 */
	public void testExample03() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/03.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/03.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	/**
	 * Many-to-Many 1
	 */
	public void testExample04() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/04.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/04.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	/**
	 * Many-to-Many 2
	 */
	public void testExample05() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/05.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/05.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	public void testExample06() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/06.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/06.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	public void testExample07() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/07.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/07.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	public void testExample08() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/08.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/08.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	public void testExample09() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/09.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/09.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	public void testExample10() {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/10.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		// HAD TO CREATE AN RDF/XML FILE AS JENA IS UNABLE TO PARSE "\o" AS TTL
		// IT THINKS YOU ARE TRYING TO ESCAPE AN "o"... NO PROBLEM WITH RDF/XML
		target.read("./test/resources/10.output.rdf");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());
	}

	public void testExample11() throws R2RMLException {
		Configuration configuration = new Configuration("./test/resources/11.config.properties");
		assertEquals("jdbc:derby:memory:testing", configuration.getConnectionURL());
		assertEquals("christophe", configuration.getUser());
		assertEquals("secret", configuration.getPassword());
		assertEquals("mapping.ttl", configuration.getMappingFile());
		assertEquals("output.ttl", configuration.getOutputFile());
		assertEquals("TURTLE", configuration.getFormat());
		assertEquals("http://www.example.org/", configuration.getBaseIRI());
	}
	
	/**
	 * Testing adhoc datatypes...
	 * @throws R2RMLException
	 */
	public void testExample14() throws R2RMLException {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/14.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/14.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());	
	}
	
	/**
	 * Testing disconnected refobjectmaps
	 * @throws R2RMLException
	 */
	public void testExample16() throws R2RMLException {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/16.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/03.output.ttl");
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());	
	}
	
	/**
	 * Testing disconnected refobjectmaps
	 * @throws R2RMLException
	 */
	public void testExample17() throws R2RMLException {
		Configuration configuration = new Configuration();
		configuration.setMappingFile("./test/resources/17.mapping.ttl");
		configuration.setConnectionURL(connectionURL);
		R2RMLProcessor engine = new R2RMLProcessor(configuration);
		engine.execute();
		Model model = engine.getDataset().getDefaultModel();
		Model target = ModelFactory.createDefaultModel();
		target.read("./test/resources/17.output.ttl");
		
		
		model.write(System.err);
		System.out.println();
		target.write(System.err);
		
		assertEquals(true, model.difference(target).isEmpty());
		assertEquals(true, target.difference(model).isEmpty());	
	}

}
