public class MyClass
{
    private String name;
    private int age;
    private String ssn;
    
    public MyClass( String name, int age, String ssn) 
    {
        this.name = name;
        this.age = age;
        this.ssn = ssn;
    }
    
    public void setName(String name) {this.name = name;}
    public String getName() {return this.name;}
    
    public void setAge(int age) {this.age = age;}
    public int getAge() {return this.age;}
    
    public void setSsn(String ssn) {this.ssn = ssn;}
    public String getSsn() {return this.ssn;}
}
