import dotenv from "dotenv";
import puppeteer from "puppeteer-extra";
import StealthPlugin from "puppeteer-extra-plugin-stealth";
import UserAgent from "user-agents";

dotenv.config();
puppeteer.use(StealthPlugin());

(async function () {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  const randomUserAgent = new UserAgent();
  page.setUserAgent(randomUserAgent.toString());

  await page.goto("https://ncore.pro/login.php");
  await page.type("input#nev", process.env.NCORE_USERNAME);
  await page.type("input[type=password]", process.env.NCORE_PASSWORD);
  await page.click("input[type=submit]");
  await page.waitForNavigation();

  console.log("Logged in successfully.");

  await browser.close();
})();
