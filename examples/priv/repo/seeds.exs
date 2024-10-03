alias Examples.Repo
alias Examples.User
alias Examples.Post

Repo.insert!(%User{name: "Casper"})
Repo.insert!(%User{name: "Jacob Marly"})

Repo.insert!(%Post{title: "How to Win Friends and Influence Poltergeists", body: "A guide to jump starting your social afterlife.", user_id: 1})
Repo.insert!(%Post{title: "Grave Expectations", body: "Misty ambitions and ghostly patrons; one orphan's haunting journey.", user_id: 2})
