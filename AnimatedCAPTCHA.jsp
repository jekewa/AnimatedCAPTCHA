<%@ page contentType="image/gif" session="true"
  import="java.awt.Color,java.awt.Font,java.awt.FontMetrics,java.awt.GradientPaint,java.awt.Graphics2D,java.awt.image.BufferedImage,java.io.IOException,java.util.Arrays,java.util.Collections,java.util.Comparator,java.util.Iterator,java.util.LinkedList,java.util.List,java.util.Random,javax.imageio.IIOImage,javax.imageio.ImageIO,javax.imageio.ImageTypeSpecifier,javax.imageio.ImageWriteParam,javax.imageio.ImageWriter,javax.imageio.metadata.IIOInvalidTreeException,javax.imageio.metadata.IIOMetadata,javax.imageio.metadata.IIOMetadataNode,javax.imageio.stream.ImageOutputStream,org.w3c.dom.Node"%><%!@SuppressWarnings("unchecked")%><%
	class ColoredCircle {
		int radius;
		int x;
		int y;
		Color darker;
		Color brighter;

		ColoredCircle(final int radius, final int x, final int y,
				final Color darker, final Color brighter) {
			this.radius = radius;
			this.x = x;
			this.y = y;
			this.darker = darker;
			this.brighter = brighter;
		}

		GradientPaint getPaint() {
			return new GradientPaint(x - radius, y - radius, darker, x
					+ radius, y + radius, brighter);
		}
	}

	final Comparator<ColoredCircle> circleComparator = new Comparator<ColoredCircle>() {
		public int compare(ColoredCircle cc1, ColoredCircle cc2) {
			if (cc1 == null)
				return cc2 == null ? 0 : -1;
			if (cc2 == null)
				return 1;

			if (cc1.radius != cc2.radius)
				return cc1.radius < cc2.radius ? -1 : 1;

			if (cc1.x != cc2.x)
				return cc2.x < cc2.x ? -1 : 1;
			if (cc1.y != cc2.y)
				return cc1.y < cc2.y ? -1 : 1;

			Color color1 = cc1.darker;
			Color color2 = cc2.darker;
			if (color1.getRed() != color2.getRed())
				return color1.getRed() < color2.getRed() ? -1 : 1;
			if (color1.getGreen() != color2.getGreen())
				return color1.getGreen() < color2.getGreen() ? -1 : 1;
			if (color1.getBlue() != color2.getBlue())
				return color1.getBlue() < color2.getBlue() ? -1 : 1;

			color1 = cc1.brighter;
			color2 = cc2.brighter;
			if (color1.getRed() != color2.getRed())
				return color1.getRed() < color2.getRed() ? -1 : 1;
			if (color1.getGreen() != color2.getGreen())
				return color1.getGreen() < color2.getGreen() ? -1 : 1;
			if (color1.getBlue() != color2.getBlue())
				return color1.getBlue() < color2.getBlue() ? -1 : 1;
			return 0;
		}
	};

	final String ELIGIBLE_CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
	final Random RANDOM = new Random();

	response.setContentType("image/gif");
	response.setHeader("Cache-Control", "no-cache");
	response.setHeader("Pragma", "no-cache");
	response.setDateHeader("Expires", 0);

	System.setProperty("java.awt.headless", "true");

	String keyName = request.getParameter("id");
	if (keyName == null || keyName.trim().isEmpty())
		keyName = "ANIMATED_CAPCHA_SESSION_KEY";

	String redraw = request.getParameter("redraw");
	if (!"redraw".equalsIgnoreCase(redraw)) {
		request.getSession().removeAttribute(keyName);
	}

	List<String> fontFamilyNames = null;
	final Object attribute = request.getSession().getServletContext()
			.getAttribute("AnimatedCaptcha-AvailableFontFamilyNames");
	if (attribute instanceof List<?>) {
		fontFamilyNames = (List<String>) attribute;
	} else {
		final String[] availableFontFamilyNames = java.awt.GraphicsEnvironment
				.getLocalGraphicsEnvironment()
				.getAvailableFontFamilyNames();
		fontFamilyNames = new LinkedList<String>();
		for (final String fontFamilyName : availableFontFamilyNames) {
			if (fontFamilyName.contains(" "))
				fontFamilyNames.add(fontFamilyName);
		}
		request.getSession()
				.getServletContext()
				.setAttribute("AnimatedCaptcha-AvailableFontFamilyNames",
						fontFamilyNames);
	}

	try {
		int charsToPrint = RANDOM.nextInt(3) + 4;
		int width = 150;
		int height = 80;
		int circlesToDraw = RANDOM.nextInt(5) + 5;
		try {
			charsToPrint = Math.max(1,
					Integer.parseInt(request.getParameter("char")));
		} catch (NumberFormatException e) {
		}
		try {
			width = Math.max(150,
					Integer.parseInt(request.getParameter("width")));
		} catch (final NumberFormatException e) {
		}
		try {
			height = Math.max(80,
					Integer.parseInt(request.getParameter("height")));
		} catch (final NumberFormatException e) {
		}
		try {
			circlesToDraw = Math.max(1,
					Integer.parseInt(request.getParameter("circles")));
		} catch (final NumberFormatException e) {
		}

		final StringBuffer finalString = new StringBuffer();
		if (!"redraw".equalsIgnoreCase(redraw)
				|| (null == request.getSession().getAttribute(keyName))
				|| (finalString.append(
						request.getSession().getAttribute(keyName))
						.length() == 0)) {
			finalString.setLength(0);
			finalString.trimToSize();
			for (int i = 0; i < charsToPrint; i++) {
				final char characterToShow = ELIGIBLE_CHARACTERS
						.charAt(RANDOM.nextInt(ELIGIBLE_CHARACTERS
								.length()));
				finalString.append(characterToShow);
			}
		}

		final List<BufferedImage> animatedImages = new LinkedList<BufferedImage>();
		final List<ColoredCircle> coloredCircles = new LinkedList<ColoredCircle>();
		final List<BufferedImage> characterImages = new LinkedList<BufferedImage>();

		int radius = height / 10;
		int diff = Math.max(2, (height / 2 - height / 10)
				/ circlesToDraw) / 2;
		while (coloredCircles.size() < circlesToDraw) {

			Color darker = new Color(RANDOM.nextInt(254),
					RANDOM.nextInt(254), RANDOM.nextInt(254));
			Color brighter = new Color(RANDOM.nextInt(254),
					RANDOM.nextInt(254), RANDOM.nextInt(254));

			radius += diff;
			if (radius >= height / 2)
				radius = height / 10;

			final ColoredCircle coloredCircle = new ColoredCircle(
					radius, RANDOM.nextInt(width),
					RANDOM.nextInt(height), darker, brighter);
			coloredCircles.add(coloredCircle);
		}

		final int horizMargin = (width / (finalString.length() + 2)) / 4;
		final int charSpace = (width - (horizMargin * 2))
				/ finalString.length();

		final Font defaultFont = new Font("Serif", Font.BOLD, 2
				* height / 3 + RANDOM.nextInt(height / 3));

		for (int i = 0; i < finalString.length(); i++) {
			final BufferedImage charImage = new BufferedImage(
					charSpace * 3, height, BufferedImage.TYPE_INT_ARGB);
			characterImages.add(charImage);
			final Graphics2D charGraphics = charImage.createGraphics();
			Color color = new Color(RANDOM.nextInt(254),
					RANDOM.nextInt(254), RANDOM.nextInt(254));

			charGraphics.setFont(defaultFont);
			if (fontFamilyNames != null && !fontFamilyNames.isEmpty()) {
				for (int f = 0; f < fontFamilyNames.size(); f++) {
					final Font font = new Font(
							fontFamilyNames.get(RANDOM
									.nextInt(fontFamilyNames.size())),
							Font.BOLD,
							(int) (8 * ((2 * height / 3) + RANDOM
									.nextInt(height / 3)) / 10));
					if (font.canDisplay(finalString.charAt(i))) {
						charGraphics.setFont(font);
						break;
					}
				}
			}

			final FontMetrics fontMetrics = charGraphics
					.getFontMetrics();
			final int charWidth = fontMetrics.charWidth(finalString
					.charAt(i));
			final int charX = charSpace
					+ ((charSpace - charWidth) / 2)
					+ (RANDOM.nextInt(charWidth / 4) / (RANDOM
							.nextBoolean() ? -8 : 8));
			int charY = (height / 2)
					+ fontMetrics.getDescent()
					+ (RANDOM.nextInt(fontMetrics.getHeight() / 4) / (RANDOM
							.nextBoolean() ? -10 : 10));

			charGraphics.translate(charX, charY);
			charGraphics.rotate((RANDOM.nextDouble() - 0.5) * 0.9);

			charGraphics.setColor(Color.BLACK);
			charGraphics.setPaint(null);
			charGraphics.drawString(finalString.substring(i, i + 1),
					(RANDOM.nextBoolean() ? 1 : -1),
					(RANDOM.nextBoolean() ? 1 : -1));

			charGraphics.setPaint(new java.awt.GradientPaint(
					charSpace / 4, height / 4, color,
					3 * charSpace / 4, 3 * height / 4, Color.WHITE));
			charGraphics.drawString(finalString.substring(i, i + 1), 0,
					0);

			charGraphics.dispose();
		}

		Color darker = new Color(RANDOM.nextInt(254),
				RANDOM.nextInt(254), RANDOM.nextInt(254));
		Color brighter = new Color(RANDOM.nextInt(254),
				RANDOM.nextInt(254), RANDOM.nextInt(254));

		int lastLetterIndex = 0;
		for (int h = height / 10; h < height / 2; h += diff) {
			final BufferedImage bufferedImage = new BufferedImage(
					width, height, BufferedImage.TYPE_INT_RGB);
			animatedImages.add(bufferedImage);
			final Graphics2D graphics = (Graphics2D) bufferedImage
					.getGraphics();

			graphics.setColor(darker);
			graphics.setPaint(new GradientPaint(0, 0, darker, width,
					height, brighter));
			graphics.fillRect(0, 0, width, height);

			for (final ColoredCircle coloredCircle : coloredCircles) {
				coloredCircle.radius += diff;
				if (coloredCircle.radius >= height / 2)
					coloredCircle.radius = height / 10;
			}

			final List<ColoredCircle> sorted = new LinkedList<ColoredCircle>(
					coloredCircles);
			Collections.sort(sorted, circleComparator);
			for (final ColoredCircle coloredCircle : sorted) {
				graphics.setPaint(coloredCircle.getPaint());
				graphics.fillOval(
						coloredCircle.x - coloredCircle.radius
								+ (RANDOM.nextBoolean() ? 1 : -1),
						coloredCircle.y - coloredCircle.radius
								+ (RANDOM.nextBoolean() ? 1 : -1),
						coloredCircle.radius * 2
								+ (RANDOM.nextBoolean() ? 1 : -1),
						coloredCircle.radius * 2
								+ (RANDOM.nextBoolean() ? 1 : -1));
			}

			int skip = RANDOM.nextInt(characterImages.size());
			while (characterImages.size() > 1
					&& skip == lastLetterIndex)
				skip = RANDOM.nextInt(characterImages.size());
			lastLetterIndex = skip;

			for (int i = 0; i < characterImages.size(); i++) {
				if (i == skip)
					continue;
				final BufferedImage charImage = characterImages.get(i);
				graphics.drawImage(charImage, horizMargin - charSpace
						+ (charSpace * i)
						+ (RANDOM.nextBoolean() ? 1 : -1),
						(RANDOM.nextBoolean() ? 1 : -1),
						charImage.getWidth(), charImage.getHeight(),
						null, null);
			}

			graphics.dispose();
		}

		final Iterator<ImageWriter> iterator = ImageIO
				.getImageWritersByFormatName("gif");
		if (iterator.hasNext()) {
			final ImageWriter imageWriter = iterator.next();
			final ImageOutputStream imageOutputStream = ImageIO
					.createImageOutputStream(response.getOutputStream());
			imageWriter.setOutput(imageOutputStream);
			imageWriter.prepareWriteSequence(null);

			for (int h = 0; h < animatedImages.size(); h++) {
				final BufferedImage bufferedImage = animatedImages
						.get(h);
				final ImageWriteParam imageWriteParam = imageWriter
						.getDefaultWriteParam();

				final IIOMetadata iioMetadata = imageWriter
						.getDefaultImageMetadata(
								new ImageTypeSpecifier(bufferedImage),
								imageWriteParam);

				final String metaFormat = iioMetadata
						.getNativeMetadataFormatName();

				if (!"javax_imageio_gif_image_1.0".equals(metaFormat)) {
					throw new IllegalArgumentException(
							"Unfamiliar gif metadata format: "
									+ metaFormat);
				}

				final Node metaDataAsTree = iioMetadata
						.getAsTree(metaFormat);

				Node child = metaDataAsTree.getFirstChild();
				while (child != null) {
					if ("GraphicControlExtension".equals(child
							.getNodeName())) {
						break;
					}
					child = child.getNextSibling();
				}

				final IIOMetadataNode iioMetadataNode = (IIOMetadataNode) child;
				iioMetadataNode.setAttribute("userDelay", "FALSE");
				iioMetadataNode.setAttribute("delayTime", "15");

				if (h == 0) {
					final IIOMetadataNode applicationExtensions = new IIOMetadataNode(
							"ApplicationExtensions");
					final IIOMetadataNode applicationExtension = new IIOMetadataNode(
							"ApplicationExtension");
					applicationExtension.setAttribute("applicationID",
							"NETSCAPE");
					applicationExtension.setAttribute(
							"authenticationCode", "2.0");
					final byte[] uo = new byte[] { 0x1, 0x0, 0x0 };
					applicationExtension.setUserObject(uo);
					applicationExtensions
							.appendChild(applicationExtension);
					metaDataAsTree.appendChild(applicationExtensions);
				}

				try {
					iioMetadata.setFromTree(metaFormat, metaDataAsTree);
				} catch (IIOInvalidTreeException e) {
					// shouldn't happen
				}

				final IIOImage iioImage = new IIOImage(bufferedImage,
						null, iioMetadata);
				imageWriter.writeToSequence(iioImage, null);
			}
			imageWriter.endWriteSequence();

			request.getSession().setAttribute(keyName,
					finalString.toString());
			imageOutputStream.close();
		} else {
			throw new RuntimeException("no encoder found for image");
		}

	} catch (final Exception e) {
		System.err.println(String.format("Unable to build image! (%s): %s", e, e.getMessage()));
	}
%>
