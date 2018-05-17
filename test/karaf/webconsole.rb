it "Web Console should be available with default credentials" do
    expect(
        command(
        'curl -s -o /dev/null -w '%{http_code}' -u karaf:karaf http://localhost:8181/system/console'
        ).stdout
    ).to match(/^200$/)
end
