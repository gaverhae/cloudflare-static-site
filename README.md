# Static Website on Cloudflare

[Cloudflare] is first and foremost a CDN, so they're pretty good at hosting
static sites. They have more complicated offerings, but this template is really
geared just towards publishing a set of static files to Cloudflare. I made
this template because, while it works pretty well and has a generous free tier,
it's in my opinion pretty badly documented.

[Clouflare]: https://www.cloudflare.com/

This setup uses Cloudflare as the hosting serving, and [DNSimple] as the
registrar, because that's what I use. Swapping out DNSimple should be pretty
simple if you prefer another registrar; Cloudflare itself sells domain names
"at cost", so that's a reasonable choice. For some projects, you may want to
eschew setting up DNS entirely and instead use the `.workers.dev` domain from
Cloudflare directly.

[DNSimple]: https://dnsimple.com

## Tooling

This template uses [Nix] and [direnv] to manage tooling. If you're not familiar
with these tools, you can visit their respective pages, or read my blog posts
about them:

* [Blog on direnv](https://www.cuddly-octo-palm-tree.com/posts/2021-12-12-tyska-direnv/).
* [Blog on nix-shell](https://www.cuddly-octo-palm-tree.com/posts/2021-12-19-tyska-nix-shell/).
* [Blog on using them together](https://www.cuddly-octo-palm-tree.com/posts/2025-08-10-tool-dependencies/).

[Nix]: https://nixos.org
[direnv]: https://direnv.net

## Getting Started

> :warning: When adding env vars to `.envrc.private`, do not forget to export
> them, i.e. each line should look something like:
>
> ```
> export ENV_VAR_NAME=super-secret-value
> ```

1. **[DNSimple]** Get a domain on [DNSimple]. Follow the instructions on the
   website to create an account and buy a domain, then navigate to your account
   page and create an access token. Add that token to `.envrc.private` as
   `DNSIMPLE_TOKEN`, and your account ID (displayed on the same page) as
   `DNSIMPLE_ACCOUNT`. If you do not want to set up a custom domain, or you
   want to use a different registrar, you'll have to edit the `tf/main.tf` file
   to match.
2. If you do not already have one, create an account on Cloudflare. Grab your
   user API key.
   > :warning: Cloudflare is discouraging the use of user API Keys, because API
   > Tokens are safer. That is true for most use-cases, but API Keys are _so
   > much more convenient_ when managing Terraform infrastructure that I
   > believe this is a better match. Do be mindful that your API Key is a very
   > important secret to keep, though.
3. Set the `CLOUDFLARE_API_KEY` env var to your Cloudflare API Key, and the
   `CLOUDFLARE_EMAIL` env var to your email (the one you gave to Cloudflare).
4. **[DNSimple]** If you're going to use Terraform, and you want to use a
   cloud-backed state file, create a bucket under "R2 Object Storage" (default
   settings are fine for this bucket). Update `tf/main.tf` to set the name of
   the bucket (`bucket` under `backend`) and the folder (`key` under `backend`)
   within the bucket that will be used to store your Terraform state.
5. **[DNSimple]** On the R2 Object Storage "Overview" page, at the bottom,
   click the "manage" button next to "API Tokens", and create a token for the
   new bucket. The token needs "Object Read & Write" permissions on the
   specific bucket you just created. Create env vars `AWS_ACCESS_KEY_ID` with
   the value displayed as "Access Key ID", `AWS_SECRET_ACCESS_KEY` with the
   value for "Secret Access Key", and "TF_VAR_s3_endpoint" with the value for
   "jurisdiction-specific endpoint". These are only shown once; if you missed
   them, simply create a new token (and delete the old one).
6. Add your Cloudflare Account ID as both `CLOUDFLARE_ACCOUNT_ID` and
   `TF_VAR_cloudflare_account_id`. You can get your Cloudflare account ID by
   navigating to "Account home" and clicking the three-vertical-dots menu after
   your account name.
7. **[DNSimple]** Double-check that you have edited the `main.tf` file as
   needed. In the `backend` block, check the fields `bucket` and `key`; in the
   `lcoals` block, check the `domain` value. No other value should need
   changing (unless you know what you're doing and you want something
   different).
8. **[DNSimple]** In the `tf` folder, run `tofu init`, then `tofu apply`. If
   everything goes well, DNSimple and Cloudflare are now aware of each other.
   Note that at this point Cloudflare is in charge of subdomains, so there is
   no other configuration needed on the DNSimple side.

### Wrangler

With the DNS in place, we can use `wrangler` to deploy the website. Open
`wrang/wrangler.jsonc` and fill in the missing values: `name` will be used to
identify the website in the Cloudflare web UI, as well as in the
Cloudflare-provider worker domain; `pattern` is where you can specify your
custom domain name. If you do not have a custom domain, remove the `pattern`
map entirely (resulting in an empty array for `routes`).

Run `deploy`.

You should now be able to navigate to your domain and see "hello". Whether you
set a custom domain or not, you should also be able to see your site at a
`workers.dev` URL, printed by wrangler. The first segment will be the string
under `name` in `wrang/wrangler.jsonc`, and the second segment will be based on
the name of your Cloudflare account.

### Going Further

You now have a running website on the internet. It says "hello". That's...
fine? But it would be nicer if it said more.

The `bin/deploy` script expects the folders `public` and `wrang/public` to be
temporary folders for its own use. Do not store anything you care about in
those.

This template is agnostic to how the set of static files are produced, as long
as they end up under `public`. Edit the `bin/deploy` script to run your file
generation (by changing the lines under `# compile static site`).

If your files are not generated, you can remove the `rm -rf public` line, and
just edit your files under `public/` directly. If you go down that path, you
should also remove the `/public/` line from `.gitignore.

> :warning: If you have images in `public/img`, the deployed version (under
> `public`) will be resized by ImageMagick. This is using settings I have found
> to work for me, but feel free to adjust them, or remove that entirely. This
> happens in the `# resize images` section of `bin/deploy`. **If you are
> working directly under `public`, rather than generating it, be mindful that
> this will change the images there in-place.**

## Copyright & License

This repo is © 2026 Gary Verhaegen. The entirety of this repo is licensed under
[0BSD], i.e. do whatever you want with it. Pull requests will not be accepted,
but feel free to fork and build on it, or fork and improve if you want to make
your own template.

Note that the license does not even require you to keep the copyright notice.
If you're forking to creating your own template inspired by this one, I'd
appreciate a shoutout, but if you're building your own website, using this as a
starting point, feel free to scrap any mention of me.

[BSD0]: https://spdx.org/licenses/0BSD.html
