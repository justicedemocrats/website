defmodule MainWebsite.PageController do
  require Logger
  use MainWebsite, :controller
  alias MainWebsite.{Candidates, ViewHelpers, DialerApi}

  @default_cosmic_bucket Application.get_env(:cosmic, :default_bucket)

  def index(conn, _params), do: render_page(conn, "index.html")

  def about(conn, _params),
    do:
      render_page(
        conn,
        "about.html",
        mission: Cosmic.get("mission", @default_cosmic_bucket),
        question_sets: Cosmic.get_type("question-sets", @default_cosmic_bucket),
        team_members: Cosmic.get_type("team-members", @default_cosmic_bucket)
      )

  def candidates(conn, _params),
    do:
      render_page(
        conn,
        "candidates.html",
        candidates: Candidates.all(),
        highlighted: Candidates.highlighted()
      )

  def get_started(conn, params) do
    akid = get_session(conn, :akid) || ""
    render_page(conn, "get_started.html", params: params, akid: akid)
  end

  def issues(conn, _params), do: render_page(conn, "issues.html")

  def joined(conn, params) do
    name = get_session(conn, :name)
    email = get_session(conn, :email)
    zip = get_session(conn, :zip)
    render_page(conn, "joined.html", params: params, name: name, email: email, zip: zip)
  end

  def sign_up(conn, params) do
    # see if we are already registered, if so, redirect, else, render
    name = get_session(conn, :name)
    email = get_session(conn, :email)
    zip = get_session(conn, :zip)

    # this is just a whitelist of supported actions so we don't have some weird injection attack
    action = case params["action"] do
      "start" -> "start"
      "calling" -> "calling"
      "events" -> "events"
      _ -> "joined"
    end

    if name && name != "" && email && email != "" && zip && zip != "" do
      redirect(conn, to: "/#{action}")
    else
      render_page(conn, "sign_up.html", params: params, name: name, zip: zip, email: email)
    end
  end

  def submit_sign_up(conn, params) do
    name = params["name"]
    email = params["email"]
    zip = params["zip"]

    result = Ak.Signup.process_signup("Justice Democrats", %{ "name" => name, "email" => email, "zip" => zip })

    conn
    |> put_session(:akid, result.body["akid"])
    |> put_session(:name, name)
    |> put_session(:email, email)
    |> put_session(:zip, zip)
    |> redirect(to: "/#{params["action"]}")
  end

  # FIXME: move this into a separate file?

  def calling(conn, params),
    do:
      render_page(
        conn,
        "calling.html",
        params: params
      )

  def calling_script(conn, params),
    do:
      render_page(
        conn,
        "calling_script.html",
        candidate: Candidates.one(params["id"]),
        params: params
      )

  def calling_dialer(conn, params) do
    expiration = get_session(conn, :dialer_expiration)

    conn =
      if params["clear"] ||
           (expiration &&
              DateTime.compare(DateTime.from_iso8601(expiration), DateTime.utc_now()) == :lt) do
        conn
        |> delete_session(:dialer_username)
        |> delete_session(:dialer_password)
        |> delete_session(:dialer_phone_number)
        |> delete_session(:dialer_request_id)
        |> delete_session(:dialer_error)
        |> delete_session(:dialer_expiration)
      else
        conn
      end

    username = get_session(conn, :dialer_username)
    password = get_session(conn, :dialer_password)
    phone_number = get_session(conn, :dialer_phone_number)
    request_id = get_session(conn, :dialer_request_id)

    error = get_session(conn, :dialer_error)
    conn = delete_session(conn, :dialer_error)

    # if we have login info
    template =
      cond do
        username && password ->
          "dialer_login.html"

        request_id ->
          "dialer_confirm_number.html"

        true ->
          "dialer_collect_info.html"
      end

    render_page(
      conn,
      "calling_dialer.html",
      candidate: Candidates.one(params["id"]),
      params: params,
      template: template,
      username: username,
      password: password,
      request_id: request_id,
      phone_number: phone_number,
      error: error
    )
  end

  def submit_dialer_confirmation(conn, params) do
    code = params["code"]
    request_id = params["request_id"]

    conn =
      if code && request_id do
        result =
          MainWebsite.DialerApi.post(
            "/verify-number/jd",
            body: %{
              code: code,
              identifier: request_id
            },
            timeout: 150_000
          )

        c =
          if result.body["username"] do
            # constructs the next instance of 9pm hawaii time zone (7am UTC)
            exp_day =
              if DateTime.utc_now().hour < 7 do
                DateTime.utc_now()
              else
                Timex.shift(DateTime.utc_now(), days: 1)
              end

            expires = %DateTime{
              year: exp_day.year,
              month: exp_day.month,
              day: exp_day.day,
              time_zone: exp_day.time_zone,
              hour: 7,
              minute: 0,
              second: 0,
              utc_offset: exp_day.utc_offset,
              zone_abbr: exp_day.zone_abbr,
              std_offset: exp_day.std_offset
            }

            d = put_session(conn, :dialer_username, result.body["username"])
            d = put_session(d, :dialer_password, result.body["password"])
            d = put_session(d, :dialer_expiration, DateTime.to_iso8601(expires))
            d
          else
            d = put_session(conn, :dialer_error, result.body["error"] || "Something went wrong!")
            d
          end

        c
      else
        c = put_session(conn, :dialer_error, "Please enter your verification code")
        c
      end

    redirect(conn, to: "/calling/dialer?id=#{params["id"]}")
  end

  def submit_dialer(conn, params) do
    phone = params["phone"]
    calling_from = params["calling_from"]
    verification_method = params["verification_method"]

    conn =
      if phone && verification_method && calling_from do
        email = get_session(conn, :email)
        name = get_session(conn, :name)

        result =
          MainWebsite.DialerApi.post(
            "/claim-login/jd",
            body:
              %{
                phone: phone,
                email: email,
                name: name,
                verification_method: verification_method,
                calling_from: calling_from
              }
              |> IO.inspect(),
            timeout: 150_000
          )

        c =
          if result.body["identifier"] do
            d = put_session(conn, :dialer_phone_number, phone)
            d = put_session(d, :dialer_request_id, result.body["identifier"])
            d
          else
            d = put_session(conn, :dialer_error, result.body["error"] || "Something went wrong!")
            d
          end

        c
      else
        c = put_session(conn, :dialer_error, "Please fill out the form")
        c
      end

    redirect(conn, to: "/calling/dialer?id=#{params["id"]}")
  end

  def assign_template_data(conn) do
    conn
    |> assign(:title, "Justice Democrats")
  end

  def render_page(conn, filename, opts \\ []) do
    conn
    |> assign_template_data
    |> render(filename, opts)
  end
end
