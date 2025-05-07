macro sayhello(name)
    return :(println("Hello, ", $name))
end

@show typeof(@macroexpand @sayhello("Alice"))
@sayhello("Alice")  # 输出：Hello, Alice




function mf(x)
    f(y) = y + x
    return f(1)
end

m = match(r"(\w+) (\d+)","June 24")
m.captures

macro myshow(ex)
    quote
        println("$($(QuoteNode(ex))) = $($ex)")
        $ex
    end
end

x = 3
@myshow x


# Match a date in format YYYY-MM-DD
date_pattern = r"(\d{4})-(\d{2})-(\d{2})"
date_match = match(date_pattern, "Event date: 2023-09-15")
date_match.captures # ["2023", "09", "15"]
# Extract all hashtags from text
hashtags = [m.match for m in eachmatch(r"#\w+", "Julia is #fast and #productive")]
# ["#fast", "#productive"]